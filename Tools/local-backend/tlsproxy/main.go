package main

import (
	"crypto/tls"
	"flag"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"time"
)

func main() {
	listen := flag.String("listen", "127.0.0.1:8443", "HTTPS listen address")
	backend := flag.String("backend", "http://127.0.0.1:7658", "backend origin")
	certFile := flag.String("cert", "cert.pem", "leaf certificate")
	keyFile := flag.String("key", "key.pem", "leaf private key")
	flag.Parse()

	target, err := url.Parse(*backend)
	if err != nil {
		log.Fatalf("parse backend: %v", err)
	}
	proxy := httputil.NewSingleHostReverseProxy(target)
	proxy.FlushInterval = -1
	proxy.ErrorLog = log.New(os.Stderr, "tlsproxy: ", log.LstdFlags)
	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Header.Del("Forwarded")
		req.Header.Del("X-Forwarded-For")
		req.Header.Set("X-Forwarded-Proto", "https")
	}

	server := &http.Server{
		Addr:              *listen,
		Handler:           proxy,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       0,
		WriteTimeout:      0,
		IdleTimeout:       120 * time.Second,
	}
	config := &tls.Config{MinVersion: tls.VersionTLS12}
	server.TLSConfig = config
	log.Printf("listening on https://%s, forwarding to %s", *listen, target)
	if err := server.ListenAndServeTLS(*certFile, *keyFile); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
