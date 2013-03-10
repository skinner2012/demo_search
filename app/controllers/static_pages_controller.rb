class StaticPagesController < ApplicationController
  autocomplete :key_word_set, :keyword

  def home
  end

  def result
    # @query_result = KeyWordSet.find_by_keyword(params[:search][:keyword])
    @query_result = KeyWordSet.where("lower(keyword) LIKE ?", "%#{params[:search][:keyword].downcase}%")
  end

  def help
  end

  def add_keyword
    @add = KeyWordSet.new(params[:add])
    if @add.save
      flash[:success] = "Add successfully!"
      redirect_to "/addkeyword" and return
    else
      render 'add_keyword'
    end
  end

  def list_all_keywords
    @keywords = KeyWordSet.all
  end

  def about
  end

  def contact
  end
end
