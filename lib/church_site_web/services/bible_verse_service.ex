defmodule ChurchSiteWeb.BibleVerseService do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://follow.it/daily-bible-promise"
  plug Tesla.Middleware.FollowRedirects

  def get_daily_verse do
    case get("/feed") do
      {:ok, response} ->
        {:ok, feed} = FeederEx.parse(response.body)
        [latest_entry | _] = feed.entries

        # Clean up the text to remove "The post ... appeared first on Daily Bible Promise"
        verse_text = latest_entry.summary
          |> String.split("The post")
          |> List.first()
          |> String.trim()

        # Extract reference from the title
        reference = latest_entry.title

        %{
          text: verse_text,
          reference: reference
        }
      _ ->
        %{
          text: "An error occurred while fetching the verse.",
          reference: "Please try again later."
        }
    end
  end
end
