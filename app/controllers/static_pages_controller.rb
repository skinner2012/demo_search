require 'net/http'
require 'json'
require 'will_paginate/array'

class StaticPagesController < ApplicationController
  autocomplete :key_word_set, :keyword, :limit => 5

  before_filter :pre_ontology, only: :ontology

  def home
    @anchors = {}
    letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    letters.each{ |letter| @anchors[letter] = 0 } 

    @search_tem = ""
    @query_result = []

    if params.has_key?(:search)
      session[:search_keyword] = params[:search][:keyword]
      escape_keyword = URI.escape(params[:search][:keyword])
      json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms?name=" + escape_keyword + "&format=JSON&limit=-1"))
      @search_term = params[:search][:keyword]
      @query_result = ActiveSupport::JSON.decode(json_result)
      # @static_pages = @query_result.paginate(page: params[:page])
    elsif params.has_key?(:page)
      escape_keyword = URI.escape(session[:search_keyword])
      json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms?name=" + escape_keyword + "&format=JSON&limit=-1"))
      @search_term = session[:search_keyword]
      @query_result = ActiveSupport::JSON.decode(json_result)
      # @static_pages = @query_result.paginate(page: params[:page])
    end

    @exact_match = [] 
    @other_hits = []

    @query_result.each do |keyword|
      if @search_term.downcase == keyword["value"].downcase
        @exact_match.push(keyword["value"])
      else
        @other_hits.push(keyword["value"])
      end
    end
  end

  def result
    # @query_result = KeyWordSet.find_by_keyword(params[:search][:keyword])
    # @query_result = KeyWordSet.where("lower(keyword) LIKE ?", "%#{params[:search][:keyword].downcase}%")
  end

  def details
    @select_term = params[:select_term]
    session[:select_term] = params[:select_term]
    @select_ontology = params[:select_ontology]
    session[:select_ontology] = params[:select_ontology]

    escape_select_term = URI.escape(params[:select_term])
    escape_select_ontology = URI.escape(params[:select_ontology])
    json_details_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms_details?name=" + escape_select_term + "&ontology=" + escape_select_ontology))
    @details_result = ActiveSupport::JSON.decode(json_details_result)

    @details_result.each do |item|
      if item["label"] == "ontologyid"
        @ontology_id = item["value"]
      elsif item["label"] == "ontologyName"
        @ontology_name = item["value"]
      elsif item["label"] == "termid"
        @term_id = item["value"]
      elsif item["label"] == "termName"
        @term_name = item["value"]
      elsif item["label"] == "bioportalURL"
        @bioportal_url = item["value"]
      elsif item["label"] == "genes"
        @gene_list = item["value"]
      elsif item["label"] == "numberOfGenes"
        @num_of_genes = item["value"]
      elsif item["label"] == "AUC"
        @auc = item["value"]
      end
    end

    if @num_of_genes <= 100
      index = 0
      @genes = ""
      @genes_for_yql = ""
      @gene_list.each do |gene|
        if index == 0
          @genes.concat(gene[1])
          @genes_for_yql.concat(gene[1])
        else
          @genes.concat("|" + gene[1])
          @genes_for_yql.concat("%7C" + gene[1])
        end
        index = index + 1
      end
    end

    # render :layout => "show_cytoscape"
    render layout: false
  end

  def ontology
    @term_name = params[:term_name]
    escape_term_name = URI.escape(params[:term_name])
    ontology_json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/get_ontologies?termname=" + escape_term_name))
    @ontology_results = ActiveSupport::JSON.decode(ontology_json_result)
    render layout: false
  end

  def display_all_genes
    escape_select_term = URI.escape(session[:select_term])
    escape_select_ontology = URI.escape(session[:select_ontology])
    json_details_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/terms_details?name=" + escape_select_term + "&ontology=" + escape_select_ontology))
    @details_result = ActiveSupport::JSON.decode(json_details_result)

    @details_result.each do |item|
      if item["label"] == "genes"
        @gene_list = item["value"]
      end
    end      
    render layout: false
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

  private

    def pre_ontology
      @term_name = params[:term_name]
      escape_term_name = URI.escape(params[:term_name])
      ontology_json_result = Net::HTTP.get(URI.parse("http://rest.mooneygroup.org/get_ontologies?termname=" + escape_term_name))
      @ontology_results = ActiveSupport::JSON.decode(ontology_json_result)

      if @ontology_results.length == 1
        redirect_to details_path(:select_ontology => @ontology_results[0]["value"], :select_term => @term_name)
      else
        render :partial => "facebox_popup"
      end
    end

end
