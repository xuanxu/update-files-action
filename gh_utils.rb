require "octokit"

def gh_token
  gh_token_from_env = ENV['GH_TOKEN'].to_s.strip
  gh_token_from_env = ENV['BOT_TOKEN'].to_s.strip if gh_token_from_env.empty?
  gh_token_from_env = ENV['GH_ACCESS_TOKEN'].to_s.strip if gh_token_from_env.empty?
  raise "!! ERROR: Invalid GitHub Token" if gh_token_from_env.empty?
  gh_token_from_env
end

def github_client
  @github_client ||= Octokit::Client.new(access_token: gh_token, auto_paginate: true)
end

def get_main_ref(repo)
  main_ref = github_client.refs(repo).select { |r| r[:ref] == "refs/heads/main" }.first
  if main_ref.nil?
    main_ref = github_client.refs(repo).select { |r| r[:ref] == "refs/heads/master" }.first
  end
  main_ref.object.sha
end

def create_file(params)
  github_client.create_contents(params[:repo],
                                params[:upload_path],
                                "Creating #{params[:filename]}",
                                File.open("#{params[:filepath].strip}").read,
                                branch: params[:branch])
end

def update_file(params)
  github_client.update_contents(params[:repo],
                                params[:upload_path],
                                "Updating #{params[:filename]}",
                                params[:sha],
                                File.open("#{params[:filepath].strip}").read,
                                branch: params[:branch])
end