---
title: 'Golang: httputil.NewSingleHostReverseProxy'
date: 2018-01-01
draft: false
description: '`ReverseProxy` is an HTTP Handler that takes an incoming request and sends it to another server, proxying the response back to the client.'
comments: true
tags:
  - golang
  - reverse-proxy
  - caddy
type: blog
---

Note: `req.Host = req.URL.Host` is required to get the proxy working. This is because according to the documentation (<https://pkg.go.dev/net/http/httputil#NewSingleHostReverseProxy>):

> `NewSingleHostReverseProxy` does not rewrite the Host header.

## `main.go`

```go
package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

func main() {
	target, err := url.Parse("https://rs.aspsp.ob.forgerock.financial:443")
	log.Printf("forwarding to -> %s%s\n", target.Scheme, target.Host)

	if err != nil {
		log.Fatal(err)
	}
	proxy := httputil.NewSingleHostReverseProxy(target)

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
 		// For why the below is needed, see the links below:
		// https://stackoverflow.com/questions/38016477/reverse-proxy-does-not-work
		// https://forum.golangbridge.org/t/explain-how-reverse-proxy-work/6492/7
		// https://stackoverflow.com/questions/34745654/golang-reverseproxy-with-apache2-sni-hostname-error
		req.Host = req.URL.Host

		proxy.ServeHTTP(w, req)
	})

	err = http.ListenAndServe(":8989", nil)
	if err != nil {
		panic(err)
	}
}
```

## Build and run

```sh
$ go run main.go &
2018/10/23 19:53:12 forwarding to -> https://rs.aspsp.ob.forgerock.financial:443
$ curl http://localhost:8989/open-banking/v2.0/accounts
{"Code":"OBRI.FR.Request.Invalid","Id":"c37baec213dd1227","Message":"An error happened when parsing the request arguments","Errors":[{"ErrorCode":"UK.OBIE.Header.Missing","Message":"Missing request header 'x-fapi-financial-id' for method parameter of type String","Url":"https://docs.ob.forgerock.financial/errors#UK.OBIE.Header.Missing"}]}%
```