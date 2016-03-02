defmodule Voorhees.Test.JSONApi.ComposableHelpersTest do
  use ExUnit.Case

  setup do
    { :ok,
      payload: %{
        "data" => %{
          "type" => "user",
          "id" => "1",
          "attributes" => %{
            "email" => "testexample.com",
            "name" => "Tester"
          },
          "relationships" => %{
            "post" => %{"data" => %{"id" => "1", "type" => "post"}}
          }
        },
        "included" => [%{
          "type" => "post",
          "id" => "1",
          "attributes" => %{
            "content" => "test content",
            "published-at" => "2016-01-01T00:00:00Z"
          }
        }],
        "meta" => %{
          "test" => "value"
        },
        "links" => %{
          "self" => "http://example.com/payload"
        }
      },

      payload_2: %{
        "data" => %{
          "type" => "user",
          "id" => "1",
          "attributes" => %{
            "email" => "testexample.com",
            "name" => "Tester"
          }
        }
      },

      payload_3: %{
        "data" => %{
          "type" => "user",
          "id" => "1",
          "attributes" => %{
            "email" => "testexample.com",
            "name" => "Tester"
          },
          "relationships" => %{
            "post" => %{"data" => %{"id" => "1", "type" => "post"}}
          }
        },
        "meta" => %{
          "test" => "value"
        },
        "links" => %{
          "self" => "http://example.com/payload"
        }
      },

      user: %User{
        email: "testexample.com",
        id: 1,
        name: "Tester"
      },
      user_2: %User{
        id: 2
      },
      admin: %User{
        email: "testexample.com",
        admin_id: 1,
        name: "Tester"
      },
      dog: %Dog{
        email: "testexample.com",
        id: 1,
        name: "Tester"
      },
      post: %Post{
        id: 1,
        published_at: Ecto.DateTime.from_erl({{2016,1,1},{0,0,0}}),
        content: "test content"
      },
      post_2: %Post{
        id: 2,
        published_at: Ecto.DateTime.from_erl({{2016,1,1},{0,0,0}}),
        content: "test content"
      },
      post_3: %Post{
        other_id: 1,
        published_at: Ecto.DateTime.from_erl({{2016,1,1},{0,0,0}}),
        content: "test content"
      },
      cat: %Cat{
        id: 1,
        published_at: Ecto.DateTime.from_erl({{2016,1,1},{0,0,0}}),
        content: "test content"
      }
    }
  end

  ## assert

  test "assert_data will not raise when record is found", %{payload: payload, user: user} do
    Voorhees.JSONApi.assert_data(payload, user)
  end

  test "assert_data will raise when record is not found because of id mismatch", %{payload: payload, user_2: user} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_data(payload, user)
    end
  end

  test "assert_data will raise when record is not found because of type mismatch", %{payload: payload, dog: dog} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_data(payload, dog)
    end
  end

  test "assert_data returns the original payload", %{payload: payload, user: user} do
    result = Voorhees.JSONApi.assert_data(payload, user)
    assert result == payload
  end

  test "assert_data will not raise if we force a type match and everything else matches", %{payload: payload, dog: dog} do
    Voorhees.JSONApi.assert_data(payload, dog, type: "user")
  end

  test "assert_data will raise if we have a mismatch on the primay key source", %{payload: payload, admin: admin} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_data(payload, admin)
    end
  end

  test "assert_data will not raise if we force a primary key source match and everything else matches", %{payload: payload, admin: admin} do
    Voorhees.JSONApi.assert_data(payload, admin, primary_key: "admin_id")
  end

  test "assert_relationship will not raise when record is found in parent record", %{payload: payload, user: user, post: post} do
    Voorhees.JSONApi.assert_relationship(payload, post, for: user)
  end

  test "assert_relationship will raise when record is not found in parent record", %{payload_2: payload, user: user, post: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_relationship(payload, post, for: user)
    end
  end

  test "assert_relationship will raise when record is not in correct name", %{payload: payload, user: user, post: post}  do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_relationship(payload, post, for: user, as: "posts")
    end
  end

  test "assert_relationship will return the payload", %{payload: payload, user: user, post: post} do
    result = Voorhees.JSONApi.assert_relationship(payload, post, for: user)
    assert result == payload
  end

  test "assert_relationship will raise when record is not incuded but we expect it", %{payload_3: payload, user: user, post: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_relationship(payload, post, for: user, included: true)
    end
  end

  test "assert_relationship will not raise when record is incuded when we expect it", %{payload: payload, user: user, post: post} do
    Voorhees.JSONApi.assert_relationship(payload, post, for: user, included: true)
  end

  test "assert_included will not raise if record is included in the payload", %{payload: payload, post: post} do
    Voorhees.JSONApi.assert_included(payload, post)
  end

  test "assert_included will return the original payload", %{payload: payload, post: post} do
    result = Voorhees.JSONApi.assert_included(payload, post)
    assert result == payload
  end

  test "assert_included will raise when record is not found because of id mismatch", %{payload: payload, post_2: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_included(payload, post)
    end
  end

  test "assert_included will raise when record is not found because of type mismatch", %{payload: payload, dog: dog} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_included(payload, dog)
    end
  end

  test "assert_included returns the original payload", %{payload: payload, post: post} do
    result = Voorhees.JSONApi.assert_included(payload, post)
    assert result == payload
  end

  test "assert_included will not raise if we force a type match and everything else matches", %{payload: payload, cat: cat} do
    Voorhees.JSONApi.assert_included(payload, cat, type: "post")
  end

  test "assert_included will raise if we have a mismatch on the primay key source", %{payload: payload, admin: admin} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.assert_included(payload, admin)
    end
  end

  test "assert_included will not raise if we force a primary key source match and everything else matches", %{payload: payload, post_3: post} do
    Voorhees.JSONApi.assert_included(payload, post, primary_key: "other_id")
  end

  ## refute
  test "refute_data will raise when record is found", %{payload: payload, user: user} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_data(payload, user)
    end
  end

  test "refute_data will not raise when record is not found because of id mismatch", %{payload: payload, user_2: user} do
    Voorhees.JSONApi.refute_data(payload, user)
  end

  test "refute_data will not raise when record is not found because of type mismatch", %{payload: payload, dog: dog} do
    Voorhees.JSONApi.refute_data(payload, dog)
  end

  test "refute_data returns the original payload", %{payload: payload, user_2: user} do
    result = Voorhees.JSONApi.refute_data(payload, user)
    assert result == payload
  end

  test "refute_data will raise if we force a type match and everything else matches", %{payload: payload, dog: dog} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_data(payload, dog, type: "user")
    end
  end

  test "refute_data will not raise if we have a mismatch on the primay key source", %{payload: payload, admin: admin} do
    Voorhees.JSONApi.refute_data(payload, admin)
  end

  test "refute_data will raise if we force a primary key source match and everything else matches", %{payload: payload, admin: admin} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_data(payload, admin, primary_key: "admin_id")
    end
  end

  test "refute_relationship will raise when record is found in parent record", %{payload: payload, user: user, post: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_relationship(payload, post, for: user)
    end
  end

  test "refute_relationship will not raise when record is not found in parent record", %{payload_2: payload, user: user, post: post} do
    Voorhees.JSONApi.refute_relationship(payload, post, for: user)
  end

  test "refute_relationship will not raise when record is not in correct name", %{payload: payload, user: user, post: post}  do
    Voorhees.JSONApi.refute_relationship(payload, post, for: user, as: "posts")
  end

  test "refute_relationship will return the payload", %{payload: payload, user: user, post: post} do
    result = Voorhees.JSONApi.refute_relationship(payload, post, for: user, as: "posts")
    assert result == payload
  end

  test "refute_included will raise if record is included in the payload", %{payload: payload, post: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_included(payload, post)
    end
  end

  test "refute_included will not raise when record is not found because of id mismatch", %{payload: payload, post_2: post} do
    Voorhees.JSONApi.refute_included(payload, post)
  end

  test "refute_included will not raise when record is not found because of type mismatch", %{payload: payload, dog: dog} do
    Voorhees.JSONApi.refute_included(payload, dog)
  end

  test "refute_included returns the original payload", %{payload: payload, post_2: post} do
    result = Voorhees.JSONApi.refute_included(payload, post)
    assert result == payload
  end

  test "refute_included will raise if we force a type match and everything else matches", %{payload: payload, cat: cat} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_included(payload, cat, type: "post")
    end
  end

  test "refute_included will not raise if we have a mismatch on the primay key source", %{payload: payload, admin: admin} do
    Voorhees.JSONApi.refute_included(payload, admin)
  end

  test "refute_included will raise if we force a primary key source match and everything else matches", %{payload: payload, post_3: post} do
    assert_raise ExUnit.AssertionError, fn ->
      Voorhees.JSONApi.refute_included(payload, post, primary_key: "other_id")
    end
  end
end
