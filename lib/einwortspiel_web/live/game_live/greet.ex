defmodule EinwortspielWeb.GameLive.Greet do
  use EinwortspielWeb, :html

  def render(assigns) do
    ~H"""
    <.header></.header>
    <.main>
      <.box class="mt-2 mb-4 text-center p-1">
        <p class="m-1">Enter your name and join the game!</p>
      </.box>
      <.box class="flex flex-col items-center my-1 pt-3">
        <.join_form id="join_form" form={to_form(%{"text" => ""})} submit_handler="join" />
      </.box>
    </.main>
    """
  end

  defp join_form(assigns) do
    ~H"""
    <.form for={@form} id={@id} phx-submit={@submit_handler} phx-hook="Empty">
      <div class="flex flex-col items-center gap-3">
        <div phx-feedback-for={@form[:text].name} class="flex flex-row">
          <.label>Name:</.label>
          <input
            type="text"
            name={@form[:text].name}
            value={Phoenix.HTML.Form.normalize_value("text", @form[:text].value)}
            class={[
              "text-base md:text-lg rounded-sm mx-0.5 py-0.5 px-1 flex-grow min-w-0",
              "phx-no-feedback:border-violet-300 phx-no-feedback:focus:border-violet-500"
            ]}
            autocomplete="off"
          />
        </div>
        <.button class="submit bg-gray-200 my-2 py-1.5 px-2" disabled>
          Join
        </.button>
      </div>
    </.form>
    """
  end
end
