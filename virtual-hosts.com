#############################################################################
#                            Test-app                                       #
#############################################################################
server {
    listen            80;
    listen       [::]:80;
    server_name  app.yphanikumar.xyz;

    location / {
         # Get resolver ip from below command
         # kubectl describe --namespace=kube-system service kube-dns
        #resolver 10.100.0.10 ipv6=off;
        resolver kube-dns.kube-system.svc.cluster.local ipv6=off;
        set $target http://springboot.default.svc.cluster.local:8080;
        proxy_read_timeout    90;
        proxy_connect_timeout 90;
        proxy_redirect        off;
        proxy_pass $target;

        proxy_set_header      X-Real-IP $remote_addr;
        proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header      Host $host;
    }
  # force https-redirects
    if ($http_x_forwarded_proto = 'http'){
    return 301 https://$host$request_uri;
    }
}
