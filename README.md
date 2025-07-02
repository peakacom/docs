# Mintlify Starter Kit

Click on `Use this template` to copy the Mintlify starter kit. The starter kit contains examples including

- Guide pages
- Navigation
- Customizations
- API Reference pages
- Use of popular components

### Development

Install the [Mintlify CLI](https://www.npmjs.com/package/mintlify) to preview the documentation changes locally. To install, use the following command

```
npm i -g mintlify
```

Run the following command at the root of your documentation (where mint.json is)

```
mintlify dev
```

### Publishing Changes

Install our Github App to autopropagate changes from youre repo to your deployment. Changes will be deployed to production automatically after pushing to the default branch. Find the link to install on your dashboard. 

#### Troubleshooting

- Mintlify dev isn't running - Run `mintlify install` it'll re-install dependencies.
- Page loads as a 404 - Make sure you are running in a folder with `mint.json`


# Extensions
## Update API Reference Script Usage

This shell script automates downloading the latest OpenAPI specification, scraping documentation pages using Mintlify, and updating the `docs.json` navigation structure for the API Reference section.

### How to run

You can execute the script directly with:

```sh
sh update-api-reference.sh
```

The script will ask you interactively to select which OpenAPI spec URL to download, or you can skip downloading by choosing option 0.

### Command line options

You can also pass the choice as a command line argument to avoid interactive prompts.

`--choice=<number>`

Select the OpenAPI spec source to download directly, where `<number>` can be:

0: Do not update OpenAPI spec (skip download)

1: Download from https://partner-test.peaka.host/v3/api-docs

2: Download from http://localhost:8080/v3/api-docs

3: Download from https://localhost:8080/v3/api-docs

4: Download from https://partner.peaka.studio/v3/api-docs

**Example:**

```sh
sh update-api-reference.sh --choice=2
```

This will download the OpenAPI spec from http://localhost:8080/v3/api-docs without any interactive prompt.

What the script does

- Downloads the OpenAPI JSON file if you choose to update it

- Cleans up the old scraped documentation folders inside api-reference/

- Runs the Mintlify scraping tool to generate the navigation object from the OpenAPI file

- Merges the first existing API Reference group with the newly scraped groups, preserving the first group

- Updates the docs.json file with the new navigation structure

- Stages the updated files in Git for commit
