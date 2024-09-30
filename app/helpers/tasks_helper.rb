module TasksHelper
  def category_select(form)
    categories = Category.joins(tasks: :commitment).where(commitments: { user_id: current_user.id }).distinct
    form.collection_select(:category_id, categories, :id, :name, { prompt: 'Selecione uma categoria' }, class: "block shadow rounded-md border border-gray-400 outline-none px-3 py-2 mt-2 w-full")
  end
end
