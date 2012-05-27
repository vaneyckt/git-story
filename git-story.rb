#!/usr/bin/env ruby

require 'set'
require 'grit'
require 'trollop'

def print(commit, suffix)
  puts "#{commit.committed_date}  #{commit.sha}  #{commit.message}  #{commit.committer}  #{suffix}"
end

def print_story(current_commit, head, merge_commits, merge_commits_directions)
  puts "\n"
  puts "Possible path"
  puts "-------------"

  print(current_commit, 'START')
  i = (merge_commits.length - 1)
  while(i >= 0)
    #direction 0 indicates there was no branch change
    print(merge_commits[i], 'MERGE') if(merge_commits_directions[i] != 0)
    i -= 1
  end
  print(head, 'HEAD')
end

def story(searched_sha, branch, repo)
  merge_commits = []
  merge_commits_directions = []
  processed_merge_commits = Set.new

  head = repo.commits(branch).first
  next_commit = head
  finished = false

  while(!finished)
    current_commit = next_commit

    #go back to previous merge commit and go to its next parent
    if(current_commit.parents.empty? or processed_merge_commits.include?(current_commit) or current_commit.sha == searched_sha)
      if(current_commit.sha == searched_sha)
        print_story(current_commit, head, merge_commits, merge_commits_directions)
      end

      done = false
      while(!done and merge_commits.any?)
        merge_commits_directions[merge_commits_directions.length - 1] += 1
        if(merge_commits_directions.last == merge_commits.last.parents.length)
          processed_merge_commits << merge_commits.pop
          merge_commits_directions.pop
        else
          done = true
        end
      end
      finished = merge_commits.empty?
      next_commit = merge_commits.last.parents[merge_commits_directions.last] if !finished
    #merge commit - update merge commits info and go to first parent of this merge commit
    elsif(current_commit.parents.length > 1)
      merge_commits << current_commit
      merge_commits_directions << 0
      next_commit = current_commit.parents[0]
    #standard commit - go to first parent
    else
      next_commit = current_commit.parents[0]
    end
  end
end

opts = Trollop::options do
  opt :commit, "Specify a commit by its sha", :type => :string, :required  => true
  opt :branch, "Specify the branch that ended up containing the commit", :type => :string, :required  => true
end

git_directory = `git rev-parse --show-toplevel`
repo = Grit::Repo.new(git_directory.chomp!)

if(repo.branches.index{|branch| branch.name.eql?(opts[:branch])}.nil?)
  puts "Error: the specified branch does not exist."
  exit(-1)
end

if(repo.commits(opts[:branch], false).index{|commit| commit.sha.eql?(opts[:commit])}.nil?)
  puts "Error: the specified commit does not exist in the specified branch."
  exit(-1)
end

story(opts[:commit], opts[:branch], repo)
