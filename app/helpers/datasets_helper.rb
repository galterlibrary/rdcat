module DatasetsHelper
  def safe_org_br(orgs)
    html = ''.html_safe
    orgs.each do |org|
      html << org
      html << '<br />'.html_safe
    end
    html
  end
end
