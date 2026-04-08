defmodule TeacherCoopWeb.WorkspaceLive.TagInput do
  use Phoenix.Component
  use Gettext, backend: TeacherCoopWeb.Gettext

  def input(assigns) do
    ~H"""
    <div>
      <label for="tags">
        <span class="label mb-1">{gettext("Tags")}</span>
        <input type="text" id="tags" name="tags" class="w-full input" />
      </label>
    </div>
    """
  end
end
