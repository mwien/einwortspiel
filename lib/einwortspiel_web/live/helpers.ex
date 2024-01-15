defmodule EinwortspielWeb.Helpers do
  use Phoenix.Component
  import EinwortspielWeb.CoreComponents

  # TODO: game_input should have width option given by rest
#
  #  attr :id, :string
  #  attr :form, :map
  #  attr :submit_handler, :string
  #  attr :rest, :global
  #  def render_textform(assigns) do
  #    ~H"""
  #    <.form
  #      for={@form}
  #      id={@id}
  #      class="inline-block m-2"
  #      phx-submit={@submit_handler}
  #      phx-hook="Diff"
  #    >
  #      <.game_input field={@form[:text]} />
  #      <.render_submit />
  #      <span class="hidden"><%= @form[:text].value %></span>
  #    </.form>
  #    """
  #  end
  #
  #  # phx-disable-with looks nice for showing
  #  # ... during send to server
  #
  #  def render_submit(assigns) do
  #    ~H"""
  #    <button class="submit" style="visibility:hidden">
  #      <.icon name="hero-paper-airplane" class="w-6 h-6" />
  #    </button>
  #    """
  #  end
  #
  #  attr :id, :any, default: nil
  #  attr :name, :any
  #  attr :label, :string, default: nil
  #  attr :value, :any
  #
  #  attr :type, :string,
  #    default: "text",
  #    values: ~w(checkbox color date datetime-local email file hidden month number password
  #               range radio search select tel text textarea time url week)
  #
  #  attr :field, Phoenix.HTML.FormField,
  #    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  #
  #  attr :errors, :list, default: []
  #  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  #  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  #  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  #  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  #
  #  attr :rest, :global,
  #    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
  #                multiple pattern placeholder readonly required rows size step)
  #
  #  slot :inner_block
  #
  #  def game_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  #    assigns
  #    |> assign(field: nil, id: assigns.id || field.id)
  #    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
  #    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
  #    |> assign_new(:value, fn -> field.value end)
  #    |> game_input()
  #  end
  # 
  #  # TODO: autocomplete not properly working in firefox
  #  # -> need to give per round unique id 
  #  # -> add this later
  #  # ----> add proper id!!!
  #
  #  def game_input(assigns) do
  #    ~H"""
  #    <div phx-feedback-for={@name} class="inline">
  #      <.label for={@id}><%= @label %></.label>
  #      <input
  #        type={@type}
  #        name={@name}
  #        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
  #        class={[
  #          "text bg-white focus:outline-none focus:ring-1 rounded-sm focus:ring-violet-500 mr-1 py-0.5 px-1 w-36 leading-8",
  #          "phx-no-feedback:border-violet-300 phx-no-feedback:focus:border-violet-500",
  #          @errors == [] && "border-violet-300 focus:border-violet-500",
  #          @errors != [] && "border-rose-400 focus:border-rose-400"
  #        ]}
  #        {@rest}
  #        autocomplete = "off"
  #      />
  #      <.error :for={msg <- @errors}><%= msg %></.error>
  #    </div>
  #    """
  #  end
  #

end
