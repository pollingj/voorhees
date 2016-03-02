defmodule User do
  defstruct id: nil,
            admin_id: nil,
            email: nil,
            name: nil
end

defmodule Dog do
  defstruct id: nil,
            email: nil,
            name: nil
end

defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :other_id
    field :content
    field :published_at, Ecto.DateTime
  end
end

defmodule Cat do
  defstruct id: nil,
            other_id: nil,
            published_at: nil,
            content: nil
end
