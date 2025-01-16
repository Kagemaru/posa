defmodule Posa.Github.Event do
  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  require Logger
  require Ash.Query

  require Ash.Resource.Preparation.Builtins
  require Ash.Resource.Preparation.Builtins
  alias Posa.Github.User
  alias Posa.Github.API

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      argument :user, :struct do
        constraints instance_of: User
      end

      accept :*
      primary? true

      change manage_relationship(:user, :user, type: :append)
    end

    read :first do
      get? true
      prepare build(limit: 1)
    end

    read :list do
      prepare build(sort: [id: :desc])
    end

    read :list_by_day do
      argument :day, :date, allow_nil?: false

      prepare build(sort: [id: :desc])

      filter expr(type(created_at, :date) == ^arg(:day))
    end

    read :months do
      prepare build(load: :month)
      prepare build(select: :created_at)

      prepare fn query, _ ->
        query
        |> Ash.Query.around_transaction(fn query, callback ->
          case callback.(query) do
            {:ok, results} ->
              results
              |> Enum.map(&Map.get(&1, :month))
              |> Enum.uniq()
              |> Enum.sort({:desc, Date})
              |> then(&{:ok, &1})

            error ->
              error
          end
        end)
      end
    end

    read :days do
      argument :month, :date
      argument :group, :boolean, default: false

      prepare build(load: :day)
      prepare build(select: :created_at)

      prepare fn query, _ ->
        query
        |> Ash.Query.around_transaction(fn query, callback ->
          month = Ash.Query.get_argument(query, :month)
          group = Ash.Query.get_argument(query, :group)

          case callback.(query) do
            {:ok, results} ->
              days =
                results
                |> Enum.map(&Map.get(&1, :day))
                |> Enum.uniq()
                |> Enum.filter(&(month == nil || Date.beginning_of_month(&1) == month))
                |> Enum.sort({:desc, Date})

              if group do
                days
                |> Enum.group_by(&Date.beginning_of_month/1)
                |> Map.to_list()
                |> List.keysort(0, {:desc, Date})
                |> Map.new()
              else
                days
              end
              |> then(&{:ok, &1})

            error ->
              error
          end
        end)
      end
    end

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for user <- User.read!() do
          case API.events(user.login) do
            {:ok, :not_modified} ->
              nil

            {:ok, events} ->
              for event <- events do
                API.EventData.transform(event)
                |> Map.put(:user, user)
                |> __MODULE__.create!()
              end

            {:err, message} ->
              Logger.info("Users sync error: #{message}")
              nil
          end
        end
        |> List.flatten()
        |> then(&{:ok, &1})
      end
    end
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
    define :update, action: :update
    define :destroy, action: :destroy

    define :list, action: :list
    define :list_by_day, action: :list_by_day
    define :first, action: :first

    define :months, action: :months
    define :days, action: :days
    define :count, action: :count
    define :sync, action: :sync
  end

  attributes do
    integer_primary_key :id, writable?: true, public?: true

    attribute :type, :string, public?: true

    attribute :actor, :map do
      public? true

      # constraints fields: [
      #               id: [type: :integer],
      #               login: [type: :string],
      #               display_login: [type: :string],
      #               gravatar_id: [type: :string],
      #               url: [type: :string],
      #               avatar_url: [type: :string]
      #             ]
    end

    attribute :repo, :map do
      public? true

      # constraints fields: [
      #               id: [type: :integer],
      #               name: [type: :string],
      #               url: [type: :string]
      #             ]
    end

    attribute :org, :map do
      public? true

      # constraints fields: [
      #               id: [type: :integer],
      #               login: [type: :string],
      #               display_login: [type: :string],
      #               gravatar_id: [type: :string],
      #               url: [type: :string],
      #               avatar_url: [type: :string]
      #             ]
    end

    attribute :payload, :map do
      public? true

      # constraints fields: [
      #               action: [type: :string],
      #               issue: [
      #                 type: :map,
      #                 constraints: [
      #                   fields: [
      #                     id: [type: :integer],
      #                     node_id: [type: :string],
      #                     url: [type: :string],
      #                     repository_url: [type: :string],
      #                     labels_url: [type: :string],
      #                     comments_url: [type: :string],
      #                     events_url: [type: :string],
      #                     html_url: [type: :string],
      #                     number: [type: :integer],
      #                     state: [type: :string],
      #                     state_reason: [type: :string],
      #                     title: [type: :string],
      #                     body: [type: :string],
      #                     user: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           name: [type: :string],
      #                           email: [type: :string],
      #                           login: [type: :string],
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           avatar_url: [type: :string],
      #                           gravatar_id: [type: :string],
      #                           url: [type: :string],
      #                           html_url: [type: :string],
      #                           followers_url: [type: :string],
      #                           following_url: [type: :string],
      #                           gists_url: [type: :string],
      #                           starred_url: [type: :string],
      #                           subscriptions_url: [type: :string],
      #                           organizations_url: [type: :string],
      #                           repos_url: [type: :string],
      #                           events_url: [type: :string],
      #                           received_events_url: [type: :string],
      #                           type: [type: :string],
      #                           site_admin: [type: :boolean],
      #                           starred_at: [type: :naive_datetime]
      #                         ]
      #                       ]
      #                     ],
      #                     labels: [
      #                       type: {:array, :map},
      #                       constraints: [
      #                         items: [
      #                           fields: [
      #                             id: [type: :integer],
      #                             node_id: [type: :string],
      #                             url: [type: :string],
      #                             description: [type: :string],
      #                             name: [type: :string],
      #                             color: [type: :string],
      #                             default: [type: :boolean]
      #                           ]
      #                         ]
      #                       ]
      #                     ],
      #                     assignee: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           name: [type: :string],
      #                           email: [type: :string],
      #                           login: [type: :string],
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           avatar_url: [type: :string],
      #                           gravatar_id: [type: :string],
      #                           url: [type: :string],
      #                           html_url: [type: :string],
      #                           followers_url: [type: :string],
      #                           following_url: [type: :string],
      #                           gists_url: [type: :string],
      #                           starred_url: [type: :string],
      #                           subscriptions_url: [type: :string],
      #                           organizations_url: [type: :string],
      #                           repos_url: [type: :string],
      #                           events_url: [type: :string],
      #                           received_events_url: [type: :string],
      #                           type: [type: :string],
      #                           site_admin: [type: :boolean],
      #                           starred_at: [type: :naive_datetime]
      #                         ]
      #                       ]
      #                     ],
      #                     assignees: [
      #                       type: {:array, :map},
      #                       constraints: [
      #                         items: [
      #                           fields: [
      #                             name: [type: :string],
      #                             email: [type: :string],
      #                             login: [type: :string],
      #                             id: [type: :integer],
      #                             node_id: [type: :string],
      #                             avatar_url: [type: :string],
      #                             gravatar_id: [type: :string],
      #                             url: [type: :string],
      #                             html_url: [type: :string],
      #                             followers_url: [type: :string],
      #                             following_url: [type: :string],
      #                             gists_url: [type: :string],
      #                             starred_url: [type: :string],
      #                             subscriptions_url: [type: :string],
      #                             organizations_url: [type: :string],
      #                             repos_url: [type: :string],
      #                             events_url: [type: :string],
      #                             received_events_url: [type: :string],
      #                             type: [type: :string],
      #                             site_admin: [type: :boolean],
      #                             starred_at: [type: :naive_datetime]
      #                           ]
      #                         ]
      #                       ]
      #                     ],
      #                     milestone: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           url: [type: :string],
      #                           html_url: [type: :string],
      #                           labels_url: [type: :string],
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           number: [type: :integer],
      #                           state: [type: :string],
      #                           title: [type: :string],
      #                           description: [type: :string],
      #                           creator: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 name: [type: :string],
      #                                 email: [type: :string],
      #                                 login: [type: :string],
      #                                 id: [type: :integer],
      #                                 node_id: [type: :string],
      #                                 avatar_url: [type: :string],
      #                                 gravatar_id: [type: :string],
      #                                 url: [type: :string],
      #                                 html_url: [type: :string],
      #                                 followers_url: [type: :string],
      #                                 following_url: [type: :string],
      #                                 gists_url: [type: :string],
      #                                 starred_url: [type: :string],
      #                                 subscriptions_url: [type: :string],
      #                                 organizations_url: [type: :string],
      #                                 repos_url: [type: :string],
      #                                 events_url: [type: :string],
      #                                 received_events_url: [type: :string],
      #                                 type: [type: :string],
      #                                 site_admin: [type: :boolean],
      #                                 starred_at: [type: :naive_datetime]
      #                               ]
      #                             ]
      #                           ],
      #                           closed_at: [type: :naive_datetime],
      #                           due_on: [type: :naive_datetime]
      #                         ]
      #                       ]
      #                     ],
      #                     locked: [type: :boolean],
      #                     active_lock_reason: [type: :string],
      #                     comments: [type: :integer],
      #                     pull_request: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           merged_att: [type: :naive_datetime],
      #                           diff_url: [type: :string],
      #                           html_url: [type: :string],
      #                           patch_url: [type: :string],
      #                           url: [type: :string]
      #                         ]
      #                       ]
      #                     ],
      #                     closed_at: [type: :naive_datetime],
      #                     created_at: [type: :naive_datetime],
      #                     updated_at: [type: :naive_datetime],
      #                     draft: [type: :boolean],
      #                     closed_by: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           name: [type: :string],
      #                           email: [type: :string],
      #                           login: [type: :string],
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           avatar_url: [type: :string],
      #                           gravatar_id: [type: :string],
      #                           url: [type: :string],
      #                           html_url: [type: :string],
      #                           followers_url: [type: :string],
      #                           following_url: [type: :string],
      #                           gists_url: [type: :string],
      #                           starred_url: [type: :string],
      #                           subscriptions_url: [type: :string],
      #                           organizations_url: [type: :string],
      #                           repos_url: [type: :string],
      #                           events_url: [type: :string],
      #                           received_events_url: [type: :string],
      #                           type: [type: :string],
      #                           site_admin: [type: :boolean],
      #                           starred_at: [type: :naive_datetime]
      #                         ]
      #                       ]
      #                     ],
      #                     body_html: [type: :string],
      #                     body_text: [type: :string],
      #                     timeline_url: [type: :string],
      #                     repository: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           name: [type: :string],
      #                           full_name: [type: :string],
      #                           license: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 key: [type: :string],
      #                                 name: [type: :string],
      #                                 url: [type: :string],
      #                                 spdx_id: [type: :string],
      #                                 node_id: [type: :string],
      #                                 html_url: [type: :string]
      #                               ]
      #                             ]
      #                           ],
      #                           forks: [type: :integer],
      #                           permissions: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 admin: [type: :boolean],
      #                                 pull: [type: :boolean],
      #                                 triage: [type: :boolean],
      #                                 push: [type: :boolean],
      #                                 maintain: [type: :boolean]
      #                               ]
      #                             ]
      #                           ],
      #                           owner: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 name: [type: :string],
      #                                 email: [type: :string],
      #                                 login: [type: :string],
      #                                 id: [type: :integer],
      #                                 node_id: [type: :string],
      #                                 avatar_url: [type: :string],
      #                                 gravatar_id: [type: :string],
      #                                 url: [type: :string],
      #                                 html_url: [type: :string],
      #                                 followers_url: [type: :string],
      #                                 following_url: [type: :string],
      #                                 gists_url: [type: :string],
      #                                 starred_url: [type: :string],
      #                                 subscriptions_url: [type: :string],
      #                                 organizations_url: [type: :string],
      #                                 repos_url: [type: :string],
      #                                 events_url: [type: :string],
      #                                 received_events_url: [type: :string],
      #                                 type: [type: :string],
      #                                 site_admin: [type: :boolean],
      #                                 starred_at: [type: :naive_datetime]
      #                               ]
      #                             ]
      #                           ],
      #                           private: [type: :boolean],
      #                           html_url: [type: :string],
      #                           description: [type: :string],
      #                           fork: [type: :boolean],
      #                           url: [type: :string],
      #                           archive_url: [type: :string],
      #                           assignees_url: [type: :string],
      #                           blobs_url: [type: :string],
      #                           branches_url: [type: :string],
      #                           collaborators_url: [type: :string],
      #                           comments_url: [type: :string],
      #                           commits_url: [type: :string],
      #                           compare_url: [type: :string],
      #                           contents_url: [type: :string],
      #                           contributors_url: [type: :string],
      #                           deployments_url: [type: :string],
      #                           downloads_url: [type: :string],
      #                           events_url: [type: :string],
      #                           forks_url: [type: :string],
      #                           git_commits_url: [type: :string],
      #                           git_refs_url: [type: :string],
      #                           git_tags_url: [type: :string],
      #                           git_url: [type: :string],
      #                           issue_comment_url: [type: :string],
      #                           issue_events_url: [type: :string],
      #                           issues_url: [type: :string],
      #                           keys_url: [type: :string],
      #                           labels_url: [type: :string],
      #                           languages_url: [type: :string],
      #                           merges_url: [type: :string],
      #                           milestones_url: [type: :string],
      #                           notifications_url: [type: :string],
      #                           pulls_url: [type: :string],
      #                           releases_url: [type: :string],
      #                           ssh_url: [type: :string],
      #                           stargazers_url: [type: :string],
      #                           statuses_url: [type: :string],
      #                           subscribers_url: [type: :string],
      #                           subscription_url: [type: :string],
      #                           tags_url: [type: :string],
      #                           teams_url: [type: :string],
      #                           trees_url: [type: :string],
      #                           clone_url: [type: :string],
      #                           mirror_url: [type: :string],
      #                           hooks_url: [type: :string],
      #                           svn_url: [type: :string],
      #                           homepage: [type: :string],
      #                           language: [type: :string],
      #                           forks_count: [type: :integer],
      #                           stargazers_count: [type: :integer],
      #                           watchers_count: [type: :integer],
      #                           size: [type: :integer],
      #                           default_branch: [type: :string],
      #                           open_issues_count: [type: :integer],
      #                           is_template: [type: :boolean],
      #                           topics: [type: {:array, :string}],
      #                           has_issues: [type: :boolean],
      #                           has_projects: [type: :boolean],
      #                           has_wiki: [type: :boolean],
      #                           has_pages: [type: :boolean],
      #                           has_downloads: [type: :boolean],
      #                           has_discussions: [type: :boolean],
      #                           archived: [type: :boolean],
      #                           disabled: [type: :boolean],
      #                           visibility: [type: :string],
      #                           pushed_at: [type: :naive_datetime],
      #                           created_at: [type: :naive_datetime],
      #                           updated_at: [type: :naive_datetime],
      #                           allow_rebase_merge: [type: :boolean],
      #                           temp_clone_token: [type: :string],
      #                           allow_squash_merge: [type: :boolean],
      #                           allow_auto_merge: [type: :boolean],
      #                           delete_branch_on_merge: [type: :boolean],
      #                           allow_update_branch: [type: :boolean],
      #                           use_sqash_pr_title_as_default: [type: :boolean],
      #                           squash_merge_commit_title: [type: :string],
      #                           squash_merge_commit_message: [type: :string],
      #                           merge_commit_title: [type: :string],
      #                           merge_commit_message: [type: :string],
      #                           allow_merge_commit: [type: :boolean],
      #                           allow_forking: [type: :boolean],
      #                           web_commit_signoff_required: [type: :boolean],
      #                           open_issues: [type: :integer],
      #                           watchers: [type: :integer],
      #                           master_branch: [type: :string],
      #                           starred_at: [type: :naive_datetime],
      #                           anonymous_access_enabled: [type: :boolean]
      #                         ]
      #                       ]
      #                     ],
      #                     performed_via_github_app: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           id: [type: :integer],
      #                           slug: [type: :string],
      #                           node_id: [type: :string],
      #                           owner: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 name: [type: :string],
      #                                 email: [type: :string],
      #                                 login: [type: :string],
      #                                 id: [type: :integer],
      #                                 node_id: [type: :string],
      #                                 avatar_url: [type: :string],
      #                                 gravatar_id: [type: :string],
      #                                 url: [type: :string],
      #                                 html_url: [type: :string],
      #                                 followers_url: [type: :string],
      #                                 following_url: [type: :string],
      #                                 gists_url: [type: :string],
      #                                 starred_url: [type: :string],
      #                                 subscriptions_url: [type: :string],
      #                                 organizations_url: [type: :string],
      #                                 repos_url: [type: :string],
      #                                 events_url: [type: :string],
      #                                 received_events_url: [type: :string],
      #                                 type: [type: :string],
      #                                 site_admin: [type: :boolean],
      #                                 starred_at: [type: :naive_datetime]
      #                               ]
      #                             ]
      #                           ],
      #                           name: [type: :string],
      #                           description: [type: :string],
      #                           external_url: [type: :string],
      #                           html_url: [type: :string],
      #                           created_at: [type: :naive_datetime],
      #                           updated_at: [type: :naive_datetime],
      #                           permissions: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 issues: [type: {:array, :string}],
      #                                 checks: [type: {:array, :string}],
      #                                 metadata: [type: {:array, :string}],
      #                                 contents: [type: {:array, :string}],
      #                                 deployments: [type: {:array, :string}],
      #                                 additional_properties: [type: :string]
      #                               ]
      #                             ]
      #                           ],
      #                           events: [type: {:array, :string}],
      #                           installations_count: [type: :integer],
      #                           client_id: [type: :string],
      #                           client_secret: [type: :string],
      #                           webhook_secret: [type: :string],
      #                           pem: [type: :string]
      #                         ]
      #                       ]
      #                     ],
      #                     author_association: [type: :string],
      #                     reactions: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           url: [type: :string],
      #                           total_count: [type: :integer],
      #                           "+1": [type: :integer],
      #                           "-1": [type: :integer],
      #                           laugh: [type: :integer],
      #                           confused: [type: :integer],
      #                           heart: [type: :integer],
      #                           hooray: [type: :integer],
      #                           eyes: [type: :integer],
      #                           rocket: [type: :integer]
      #                         ]
      #                       ]
      #                     ]
      #                   ]
      #                 ]
      #               ],
      #               comment: [
      #                 type: :map,
      #                 constraints: [
      #                   fields: [
      #                     id: [type: :integer],
      #                     node_id: [type: :string],
      #                     url: [type: :string],
      #                     body: [type: :string],
      #                     body_text: [type: :string],
      #                     body_html: [type: :string],
      #                     html_url: [type: :string],
      #                     user: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           name: [type: :string],
      #                           email: [type: :string],
      #                           login: [type: :string],
      #                           id: [type: :integer],
      #                           node_id: [type: :string],
      #                           avatar_url: [type: :string],
      #                           gravatar_id: [type: :string],
      #                           url: [type: :string],
      #                           html_url: [type: :string],
      #                           followers_url: [type: :string],
      #                           following_url: [type: :string],
      #                           gists_url: [type: :string],
      #                           starred_url: [type: :string],
      #                           subscriptions_url: [type: :string],
      #                           organizations_url: [type: :string],
      #                           repos_url: [type: :string],
      #                           events_url: [type: :string],
      #                           received_events_url: [type: :string],
      #                           type: [type: :string],
      #                           site_admin: [type: :boolean],
      #                           starred_at: [type: :naive_datetime]
      #                         ]
      #                       ]
      #                     ],
      #                     created_at: [type: :naive_datetime],
      #                     updated_at: [type: :naive_datetime],
      #                     issue_url: [type: :string],
      #                     author_association: [type: :string],
      #                     performed_via_github_app: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           id: [type: :integer],
      #                           slug: [type: :string],
      #                           node_id: [type: :string],
      #                           owner: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 name: [type: :string],
      #                                 email: [type: :string],
      #                                 login: [type: :string],
      #                                 id: [type: :integer],
      #                                 node_id: [type: :string],
      #                                 avatar_url: [type: :string],
      #                                 gravatar_id: [type: :string],
      #                                 url: [type: :string],
      #                                 html_url: [type: :string],
      #                                 followers_url: [type: :string],
      #                                 following_url: [type: :string],
      #                                 gists_url: [type: :string],
      #                                 starred_url: [type: :string],
      #                                 subscriptions_url: [type: :string],
      #                                 organizations_url: [type: :string],
      #                                 repos_url: [type: :string],
      #                                 events_url: [type: :string],
      #                                 received_events_url: [type: :string],
      #                                 type: [type: :string],
      #                                 site_admin: [type: :boolean],
      #                                 starred_at: [type: :naive_datetime]
      #                               ]
      #                             ]
      #                           ],
      #                           name: [type: :string],
      #                           description: [type: :string],
      #                           external_url: [type: :string],
      #                           html_url: [type: :string],
      #                           created_at: [type: :naive_datetime],
      #                           updated_at: [type: :naive_datetime],
      #                           permissions: [
      #                             type: :map,
      #                             constraints: [
      #                               fields: [
      #                                 issues: [type: {:array, :string}],
      #                                 checks: [type: {:array, :string}],
      #                                 metadata: [type: {:array, :string}],
      #                                 contents: [type: {:array, :string}],
      #                                 deployments: [type: {:array, :string}],
      #                                 additional_properties: [type: :string]
      #                               ]
      #                             ]
      #                           ],
      #                           events: [type: {:array, :string}],
      #                           installations_count: [type: :integer],
      #                           client_id: [type: :string],
      #                           client_secret: [type: :string],
      #                           webhook_secret: [type: :string],
      #                           pem: [type: :string]
      #                         ]
      #                       ]
      #                     ],
      #                     reactions: [
      #                       type: :map,
      #                       constraints: [
      #                         fields: [
      #                           url: [type: :string],
      #                           total_count: [type: :integer],
      #                           "+1": [type: :integer],
      #                           "-1": [type: :integer],
      #                           laugh: [type: :integer],
      #                           confused: [type: :integer],
      #                           heart: [type: :integer],
      #                           hooray: [type: :integer],
      #                           eyes: [type: :integer],
      #                           rocket: [type: :integer]
      #                         ]
      #                       ]
      #                     ]
      #                   ]
      #                 ]
      #               ],
      #               pages: [
      #                 type: :map,
      #                 constraints: [
      #                   fields: [
      #                     page_name: [type: :string],
      #                     title: [type: :string],
      #                     summary: [type: :string],
      #                     action: [type: :string],
      #                     sha: [type: :string],
      #                     html_url: [type: :string]
      #                   ]
      #                 ]
      #               ]
      #             ]
    end

    attribute :public, :boolean, public?: true
    attribute :created_at, :naive_datetime, public?: true
  end

  calculations do
    calculate :day, :date, expr(created_at)
    calculate :month, :date, expr(fragment(&Date.beginning_of_month/1, day))

    calculate :from_member?,
              :boolean,
              expr(^ref([:actor, :login], :login) in fragment(&Posa.Github.Member.logins!/0))

    # expr(^ref([:actor, :login] in fragment(&Member.logins/0, nil)))
  end

  relationships do
    belongs_to :user, User, attribute_type: :integer
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, "activity"
    publish_all :update, "activity"
    publish_all :destroy, "activity"

    publish_all :create, ["event", [nil, "created"], [nil, :id]]
    publish_all :update, ["event", [nil, "updated"], [nil, :id]], previous_values?: true
    publish_all :destroy, ["event", [nil, "destroyed"], [nil, :id]]

    # publish :sync, ["event", [nil, "synched"], [nil, :id]], previous_values?: true, event: "sync"
  end
end
