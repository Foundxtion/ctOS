{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
  services.openldap = {
    enable = true;

    /* Enable plained and secure connections */
    urlList = [ "ldap://" "ldaps://"];

	settings = {
      attrs = {
        olcLogLevel = "conns config";

        /* settings for acme ssl */
        olcTLSCACertificateFile = "/var/lib/acme/${server.openldap.domain}/full.pem";
        olcTLSCertificateFile = "/var/lib/acme/${server.openldap.domain}/cert.pem";
        olcTLSCertificateKeyFile = "/var/lib/acme/${server.openldap.domain}/key.pem";
        olcTLSCipherSuite = "HIGH:MEDIUM:+3DES:+RC4:+aNULL";
        olcTLSCRLCheck = "none";
        olcTLSVerifyClient = "never";
        olcTLSProtocolMin = "3.1";
      };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];

        "olcDatabase={1}mdb".attrs = {
          objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";

          olcSuffix = server.openldap.olcSuffix;

          /* TODO: this way of defining admin password is strongly not recommended */
          olcRootDN = server.openldap.olcRootDN;
          olcRootPW = "${secrets.openldap.adminPW}";

          olcAccess = [
            /* custom access rules for userPassword attributes */
            ''{0}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''

            /* allow read on anything else */
            ''{1}to *
                by * read''
          ];
        };
      };
    };

  };

  systemd.services.openldap = {
    wants = [ "acme-${server.openldap.domain}.service" ];
    after = [ "acme-${server.openldap.domain}.service" ];
  };

  /* make acme certificates accessible by openldap */
  security.acme.defaults.group = "certs";
  users.groups.certs.members = [ "openldap" ];

  security.acme.certs.${server.openldap.domain} = {
    extraDomainNames = [];
  };
}
