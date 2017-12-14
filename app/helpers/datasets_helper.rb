module DatasetsHelper
  def safe_org_br(orgs)
    html = ''.html_safe
    orgs.each do |org|
      html << org
      html << '<br />'.html_safe
    end
    html
  end

  def institutes_and_centers_select_options
    grouped_options_for_select(
      Organization.institute_or_center.group_by(&:group_name).inject({}) {|h, grp|
        h[grp.first] = grp.second.map {|x| [x.name, x.id] }
        h
      },
      @dataset.orgs(:institute_or_center).pluck(:id)
    )
  end

end
