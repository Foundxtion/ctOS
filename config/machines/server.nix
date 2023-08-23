let
  grafana_settings = {
    server = {
      # Listening address
      http_addr = "127.0.0.1";
      http_port = 3000;

      # Grafana needs to know on which domain and URL it is running
      domain = "s3l4h.com";
      root_url = "https://grafana.s3l4h.com/";
    };
  };
  portunus_port = 8080;
in
{
  ddclient = {
    protocol = "namecheap";
    web = "dynamicdns.park-your-domain.com/getip";
    login = "s3l4h.com";
    # password is a secret
    server = "dynamicdns.park-your-domain.com";
    domain = "";
  };
  grafana.settings = grafana_settings;
  nginx.virtualHosts = {
    "s3l4h.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/landingpage";
    };
    "www.s3l4h.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/landingpage";
    };	
    "grafana.s3l4h.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = "proxy_set_header Host grafana.s3l4h.com;";
        proxyPass = "http://${toString grafana_settings.server.http_addr}:${toString grafana_settings.server.http_port}/";
        proxyWebsockets = true;
      };
    };
  };

  mailserver = {
    fqdn = "s3l4h.com";
    domains = ["s3l4h.com"];
  };
}
