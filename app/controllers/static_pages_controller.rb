require 'net/http'
require 'json'

class StaticPagesController < ApplicationController
  autocomplete :key_word_set, :keyword, :limit => 5

  def home
    if params.has_key?(:search)
      json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms?name=" + params[:search][:keyword] + "&format=JSON&limit=-1"))
      @query_result = ActiveSupport::JSON.decode(json_result)
   end
  end

  def result
    # @query_result = KeyWordSet.find_by_keyword(params[:search][:keyword])
    # @query_result = KeyWordSet.where("lower(keyword) LIKE ?", "%#{params[:search][:keyword].downcase}%")
    # json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms?name=" + params[:search][:keyword] + "&format=JSON&limit=-1"))
    # @query_result = ActiveSupport::JSON.decode(json_result)
  end

  def details
    @terms = params[:terms]
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
