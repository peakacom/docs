#!/bin/sh

# File paths
DOCS_JSON="docs.json"
SCRAPED_RAW="scraped_raw.txt"
SCRAPED_JSON="scraped.json"
TMP_FILE="docs.tmp.json"
OPENAPI_PATH="api-reference/peaka-openapi.json"


echo "🧹 Cleaning up old folders under api-reference..."
find api-reference -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

echo "🔄 Running Mintlify scraping..."
npx --yes @mintlify/scraping@latest openapi-file "$OPENAPI_PATH" -o api-reference > "$SCRAPED_RAW"

# Skip the prefix line (assumed to be the first line)
tail -n +2 "$SCRAPED_RAW" > "$SCRAPED_JSON"

# Extract API Reference group
API_DOC_GROUP=$(jq -c -e '.navigation.tabs[] | select(.tab == "API Reference") | .groups[0]' "$DOCS_JSON")
if [ $? -ne 0 ] || [ -z "$API_DOC_GROUP" ]; then
  echo "❌ API_DOC_GROUP not found or empty."
  exit 1
fi

echo "API_DOC_GROUP:"
echo "$API_DOC_GROUP"

# Check if scraped.json contains valid JSON
if ! jq empty "$SCRAPED_JSON" 2>/dev/null; then
  echo "❌ scraped.json is not valid JSON or is empty."
  exit 1
fi

# Create new API Reference tab with merged groups (apiDocGroup first)
NEW_API_REF_TAB=$(jq -n \
  --argjson apiDocGroup "$API_DOC_GROUP" \
  --argjson scrapedGroups "$(jq '.' "$SCRAPED_JSON")" \
  '{
    tab: "API Reference",
    groups: ([$apiDocGroup] + $scrapedGroups)
  }'
)

echo "NEW_API_REF_TAB:"
echo "$NEW_API_REF_TAB"

# Read the root object from docs.json
ROOT=$(jq '.' "$DOCS_JSON")

# Create updated tabs array, replacing only the API Reference tab
UPDATED_TABS=$(jq --argjson newApiRefTab "$NEW_API_REF_TAB" '
  .navigation.tabs | map(
    if .tab == "API Reference" then
      $newApiRefTab
    else
      .
    end
  )
' "$DOCS_JSON")

# Build new docs.json content with updated tabs
jq -n \
  --argjson root "$ROOT" \
  --argjson updatedTabs "$UPDATED_TABS" \
  '
  $root
  | .navigation.tabs = $updatedTabs
  ' > "$TMP_FILE"

# Check if the updated docs.json is empty and error if so
if [ ! -s "$TMP_FILE" ]; then
  echo "❌ Error: $TMP_FILE is empty after update."
  exit 1
fi


# Replace original docs.json
mv "$TMP_FILE" "$DOCS_JSON"
rm "$SCRAPED_RAW" "$SCRAPED_JSON"

# Add changes
git add api-reference/**

echo "✅ Successfully updated API Reference in docs.json"
