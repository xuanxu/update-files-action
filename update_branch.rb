require_relative "gh_utils"

issue_id = ENV["ISSUE_ID"]
pdf_path = ENV["PDF_PATH"].to_s.strip
jats_path = ENV["JATS_PATH"].to_s.strip
crossref_path = ENV["CROSSREF_PATH"].to_s.strip
papers_repo = ENV["PAPERS_REPO"]
branch_prefix = ENV["BRANCH_PREFIX"]
papers_repo_main_banch = ENV["PAPERS_REPO_MAIN_BRANCH"] || "main"

id = "%05d" % issue_id
branch = branch_prefix.empty? ? id.to_s : "#{branch_prefix}.#{id}"
ref = "heads/#{branch}"

begin
  # Check branch existence
  github_client.ref(papers_repo, ref)
  # Delete old branch and create it again
  github_client.delete_ref(papers_repo, ref)
  github_client.create_ref(papers_repo, ref, get_main_ref(papers_repo))
rescue Octokit::NotFound
  # Create branch if it doesn't exist
  github_client.create_ref(papers_repo, ref, get_main_ref(papers_repo))
end

pdf_uploaded_path = "#{branch}/10.21105.#{branch}.pdf"
jats_uploaded_path = "#{branch}/10.21105.#{branch}.jats"
crossref_uploaded_path = "#{branch}/10.21105.#{branch}.crossref.xml"

# Update PDF file if present
if !pdf_path.empty? && File.exist?(pdf_path)
  sha = github_client.contents(papers_repo, path: pdf_uploaded_path).sha rescue nil

  params = { repo: papers_repo,
             upload_path: pdf_uploaded_path,
             filename: "10.21105.#{branch}.pdf",
             filepath: pdf_path,
             branch: branch,
             sha: sha }

  pdf_gh_response = sha.nil? ? create_file(params) : update_file(params)
  system("echo 'PDF updated! -> #{pdf_gh_response.content.html_url}'")
end

# Update Crossref XML file if present
if !crossref_path.empty? && File.exist?(crossref_path)
  sha = github_client.contents(papers_repo, path: crossref_uploaded_path).sha rescue nil

  params = { repo: papers_repo,
             upload_path: crossref_uploaded_path,
             filename: "10.21105.#{branch}.crossref.xml",
             filepath: crossref_path,
             branch: branch,
             sha: sha }

  crossref_gh_response = sha.nil? ? create_file(params) : update_file(params)
  system("echo 'Crossref XML updated! -> #{crossref_gh_response.content.html_url}'")
end

# Update JATS file if present
if !jats_path.empty? && File.exist?(jats_path)
  sha = github_client.contents(papers_repo, path: jats_uploaded_path).sha rescue nil

  params = { repo: papers_repo,
             upload_path: jats_uploaded_path,
             filename: "10.21105.#{branch}.jats",
             filepath: jats_path,
             branch: branch,
             sha: sha }

  jats_gh_response = sha.nil? ? create_file(params) : update_file(params)
  system("echo 'JATS file updated! -> #{jats_gh_response.content.html_url}'")
end
