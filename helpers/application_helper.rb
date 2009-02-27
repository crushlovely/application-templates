module ApplicationHelper

  def body_class
    [controller.controller_name, "#{controller.controller_name}-#{controller.action_name}"].join(' ')
  end

  def google_analytics_tracking_code
    if Rails.env.production?
    <<-HERE

    <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("UA-525540-59");
      pageTracker._trackPageview();
      } catch(err) {}
    </script>
HERE
    end
  end

end
