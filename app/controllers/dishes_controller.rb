class DishesController < ApplicationController
  def index
    @q = Dish.ransack(params.fetch("q", nil))
    @dishes = @q.result(:distinct => true).includes(:cuisine, :bookmarks, :fans, :specialists).page(params.fetch("page", nil)).per(10)
    
    render("dishes_templates/index.html.erb")
  end

  def show
    @bookmark = Bookmark.new
    @dish = Dish.find(params.fetch("id"))
    
    time_ago_sec = Time.now - Dish.find(params.fetch("id")).updated_at
    
    time_ago_min = time_ago_sec / 60
    
    time_ago_hr = time_ago_min / 60
    
    time_ago_day = time_ago_hr / 24
    
    if time_ago_min < 60
      @time_ago = time_ago_min.round()
      @unit = "minutes ago"
    elsif time_ago_hr < 24
      @time_ago = time_ago_hr.round()
      @unit = "hours ago"
    else
      @time_ago = time_ago_day.round()
      @unit = "days ago"
    end

    render("dishes_templates/show.html.erb")
  end

  def new
    @dish = Dish.new

    render("dishes_templates/new.html.erb")
  end

  def create
    @dish = Dish.new

    @dish.name = params.fetch("name")
    @dish.cuisine_id = params.fetch("cuisine_id")

    save_status = @dish.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/dishes/new", "/create_dish"
        redirect_to("/dishes")
      else
        redirect_back(:fallback_location => "/", :notice => "Dish created successfully.")
      end
    else
      render("dishes_templates/new.html.erb")
    end
  end

  def edit
    @dish = Dish.find(params.fetch("id"))

    render("dishes_templates/edit.html.erb")
  end

  def update
    @dish = Dish.find(params.fetch("id"))

    @dish.name = params.fetch("name")
    @dish.cuisine_id = params.fetch("cuisine_id")

    save_status = @dish.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/dishes/#{@dish.id}/edit", "/update_dish"
        redirect_to("/dishes/#{@dish.id}", :notice => "Dish updated successfully.")
      else
        redirect_back(:fallback_location => "/", :notice => "Dish updated successfully.")
      end
    else
      render("dishes_templates/edit.html.erb")
    end
  end

  def destroy
    @dish = Dish.find(params.fetch("id"))

    @dish.destroy

    if URI(request.referer).path == "/dishes/#{@dish.id}"
      redirect_to("/", :notice => "Dish deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Dish deleted.")
    end
  end
end
