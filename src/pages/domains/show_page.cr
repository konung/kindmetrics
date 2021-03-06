class Domains::ShowPage < SecretGuestLayout
  needs domains : DomainQuery?
  needs domain : Domain
  needs total_unique : Int64
  needs total_sum : Int64
  needs total_bounce : Int64
  needs total_unique_previous : Int64
  needs total_previous : Int64
  needs total_bounce_previous : Int64
  needs period : String
  needs period_string : String
  needs share_page : Bool = false
  needs site_path : String = ""
  needs active : String = "Dashboard"
  needs goal : Goal?
  quick_def page_title, "Analytics for " + @domain.address

  def content
    render_header
    if total_sum == 0
      m AddTrackingComponent, domain: @domain
    else
      render_query_tabs
      render_total
      div class: "gradient-color" do
        div class: "mb-6" do
          div class: "" do
            render_canvas
          end
        end
      end
      render_the_rest
    end
  end

  def render_query_tabs
    return if goal.nil? && site_path.empty?
    div class: "gradient-color" do
      div class: "px-2 sm:px-0 pt-4" do
        if !goal.nil?
          taber("Goal", goal.not_nil!.name, share_page? ? Share::Show.with(**generate_share_params("goal")) : Domains::Show.with(**generate_params("goal")))
        end
        if !site_path.empty?
          taber("Path", site_path, share_page? ? Share::Show.with(**generate_share_params("site_path")) : Domains::Show.with(**generate_params("site_path")))
        end
      end
    end
  end

  def taber(name : String, value : String, close)
    div class: "inline-block mini-card text-black mr-2" do
      span class: "mr-2" do
        text "#{name}: #{value}"
      end
      link to: close do
        text "x"
      end
    end
  end

  def render_total
    m TotalRowComponent, @total_unique, @total_sum, @total_bounce, @total_unique_previous, @total_previous, @total_bounce_previous
  end

  def render_canvas
    div style: "max-height:320px;" do
      m DaysLoaderComponent, domain: @domain, period: @period, goal: @goal, site_path: site_path
    end
  end

  def render_the_rest
    div class: "p-2 sm:p-0 my-3 mb-6" do
      div class: "w-full grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6" do
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/pages", goal: @goal, period: @period, site_path: site_path
        end
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/referrer", goal: @goal, period: @period, site_path: site_path
          if @share_page
            m DetailsLinkComponent, link: Share::Referrer::Index.with(@domain.hashid, @period).url
          else
            m DetailsLinkComponent, link: Domains::Referrer::Index.with(@domain, @period).url
          end
        end
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/countries", goal: @goal, period: @period, site_path: site_path, style: "relative clear-both"
          if @share_page
            m DetailsLinkComponent, link: Share::Countries::Index.with(@domain.hashid, @period).url
          else
            m DetailsLinkComponent, link: Domains::Countries::Index.with(@domain, @period).url
          end
        end
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/devices/device", goal: @goal, period: @period, site_path: site_path
        end
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/devices/browser", goal: @goal, period: @period, site_path: site_path
        end
        div class: "card" do
          m LoaderComponent, domain: @domain, url: "data/devices/os", goal: @goal, period: @period, site_path: site_path
        end
      end
      render_goals unless @goal
      render_promo if share_page? && current_user.nil?
    end
  end

  def render_promo
    m PromoComponent, domain
  end

  def render_goals
    div data_controller: "loader", data_loader_period: @period, data_loader_url: "/domains/#{@domain.id}/data/goals", site_path: site_path
  end

  def render_header
    m HeaderComponent, domain: @domain, current_url: context.request.path, domains: @domains, total_sum: @total_sum, period_string: @period_string, period: @period, show_period: total_sum > 0, share_page: @share_page, current_user: current_user
  end

  def generate_params(kind : String)
    {
      domain_id: domain.id,
      goal_id:   !goal.nil? && kind != "goal" ? goal.not_nil!.id : 0_i64,
      site_path: site_path.empty? || kind == "site_path" ? "" : site_path,
    }
  end

  def generate_share_params(kind : String)
    {
      share_id:  domain.hashid,
      goal_id:   !goal.nil? && kind != "goal" ? goal.not_nil!.id : 0_i64,
      site_path: site_path.empty? || kind == "site_path" ? "" : site_path,
    }
  end
end
