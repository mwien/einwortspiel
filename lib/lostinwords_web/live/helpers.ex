defmodule LostinwordsWeb.Helpers do
  use Phoenix.Component
  import Phoenix.HTML.Form

  def render_textform(assigns) do
    ~H"""
    <.form
      :let={form}
      for={:value}
      id={@id}
      style="display:inline"
      phx-submit={@submit_handler}
      phx-hook="Diff"
    >
      <%= text_input(form, :text,
        value: @value,
        class:
          "text
      bg-gray-50 border border-gray-300 text-gray-900 rounded-lg w-32 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
      ) %>
      <.render_submit />
      <span class="hidden" hidden><%= @value %></span>
    </.form>
    """
  end

  # phx-disable-with looks nice for showing
  # ... during send to server

  defp render_submit(assigns) do
    ~H"""
    <button class="submit" style="display:none">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
        <path d="M24 0l-6 22-8.129-7.239 7.802-8.234-10.458 7.227-7.215-1.754 24-12zm-15 16.668v7.332l3.258-4.431-3.258-2.901z" />
      </svg>
    </button>
    """
  end
end
