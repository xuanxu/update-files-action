# Open Journals :: Upload files

This action creates a topic branch for a paper in the corresponding Open Journal's papers repository and updates the paper files (pdf/jats/crossref xml).

## Usage

Usually this action is used as a step in a workflow that also includes other steps for generating the paper files.

### Inputs

The action accepts the following inputs:

- **papers_repo**: Required. The repository containing the published and submitted papers in `owner/reponame` format.
- **issue_id**: Required. The issue number of the submission of the paper.
- **pdf_path**: Optional. The path to a paper pdf file to add to the paper's branch.
- **crossref_path**: Optional. The path to a crossref xml file with the deposit metadata to add to the paper's branch.
- **jats_path**: Optional. The path to a jats file with the paper metadata to add to the paper's branch.
- **branch_prefix**: Optional. The prefix of the name of the paper's branch.
- **bot_token**: Optional. The GitHub access token to be used to upload files. Default: `ENV['GH_ACCESS_TOKEN']`

### Example

Use it adding it as a step in a workflow `.yml` file in your repo's `.github/workflows/` directory and passing your custom input values (here's an example for uploading just pdf and crossref files, showing how to pass input values from diferent sources: workflow inputs, secrets or directly).

````yaml
on:
  workflow_dispatch:
   inputs:
      issue_id:
        description: 'The issue number of the submission'
jobs:
  processing:
    runs-on: ubuntu-latest
    env:
      GH_ACCESS_TOKEN: ${{ secrets.BOT_TOKEN }}
    steps:
      - name: Update files for a published paper
        uses: xuanxu/update-files-action@main
        with:
          papers_repo: myorg/myjournal-papers
          branch_prefix: myjournal
          issue_id: ${{ github.event.inputs.issue_id }}
          pdf_path: docs/paper.pdf
          crossref_path: docs/paper.jats
```
