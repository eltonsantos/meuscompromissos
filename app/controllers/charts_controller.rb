class ChartsController < ApplicationController
  def index
    @tarefa = Task.first
    render partial: 'charts/index'
  end
end