{config, pkgs, ...}:
let
  secrets = import ../secrets.nix;
  server = import ../machines/server.nix;
in
{
  services.openldap = {
    enable = true;

    /* Enable plained and secure connections */
    urlList = [ "ldap://" ];

	settings = {
      attrs = {
        olcLogLevel = "conns config";
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
}
