class QuotesController < ApplicationController
  # GET /quotes
  # GET /quotes.json
  def index
    @categories = getCategories #Category.all
    @authors = getAuthors
    
    if params[:category]
      category = Category.find_by_name(params[:category])
      unless category
        @quotes = []
      else	
        @quotes = Quote.find_all_by_category_id(category.id)
      end	
    else
      @quotes = Quote.all
    end
    @tags = getTags
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @quotes }
      format.json { render :json => @quotes }
    end
  end

  # GET /quotes/1
  # GET /quotes/1.json
  def show
    @quote = Quote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @quote }
    end
  end

  # GET /quotes/new
  # GET /quotes/new.json
  def new
    @quote = Quote.new
    @categories = Category.all
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @quote }
    end
  end

  # GET /quotes/1/edit
  def edit
    @categories = Category.all
    @quote = Quote.find(params[:id])
  end

  # POST /quotes
  # POST /quotes.json
  def create
    @quote = Quote.new(params[:quote])

    respond_to do |format|
      if @quote.save
        format.html { redirect_to @quote, :notice => 'Quote was successfully created.' }
        format.json { render :json => @quote, :status => :created, :location => @quote }
      else
        format.html { render :action => "new" }
        format.json { render :json => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /quotes/1
  # PUT /quotes/1.json
  def update
    @quote = Quote.find(params[:id])

    respond_to do |format|
      if @quote.update_attributes(params[:quote])
        format.html { redirect_to @quote, :notice => 'Quote was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @quote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /quotes/1
  # DELETE /quotes/1.json
  def destroy
    @quote = Quote.find(params[:id])
    @quote.destroy

    respond_to do |format|
      format.html { redirect_to quotes_url }
      format.json { head :no_content }
    end
  end
end
