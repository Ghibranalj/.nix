{ config, lib, pkgs, ... }:

{
  services.nginx = lib.mkForce {
    enable = true;

    # Recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Configure virtual hosts for each service
    virtualHosts = {
      # Main jellyfin hostname
      "jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096"; # Jellyfin port
          proxyWebsockets = true;
        };
      };

      # Sonarr subdomain
      "sonarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8989";
          proxyWebsockets = true;
        };
      };

      # Radarr subdomain
      "radarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:7878";
          proxyWebsockets = true;
        };
      };

      # Lidarr subdomain
      "lidarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8686";
          proxyWebsockets = true;
        };
      };

      # Readarr subdomain
      "readarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8787";
          proxyWebsockets = true;
        };
      };

      # Prowlarr subdomain
      "prowlarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:9696";
          proxyWebsockets = true;
        };
      };

      # Bazarr subdomain
      "bazarr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6767";
          proxyWebsockets = true;
        };
      };

      # Jellyseerr subdomain
      "jellyseerr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:5055";
          proxyWebsockets = true;
        };
      };

      # Transmission subdomain
      "transmission.jellyfin.local" = {
        locations."/" = {
          proxyPass =
            "http://127.0.0.1:9091"; # Default transmission web UI port
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      # Sabnzbd subdomain
      "sabnzbd.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080"; # Default Sabnzbd port
          proxyWebsockets = true;
        };
      };

      # Unmanic subdomain
      "unmanic.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://localhost:8889";
          proxyWebsockets = true;
        };
      };

      # Flaresolverr subdomain
      "flaresolverr.jellyfin.local" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8191"; # Flaresolverr port
          proxyWebsockets = true; # Though Flaresolverr might not use websockets, it's harmless to include
        };
      };

      # Admin Dashboard subdomain
      "admin.jellyfin.local" = {
        locations."/" = {
          root = pkgs.writeTextDir "index.html" ''
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Nixarr Admin Dashboard</title>
              <!-- TailwindCSS -->
              <script src="https://cdn.tailwindcss.com"></script>
              <!-- Lucide Icons -->
              <script src="https://unpkg.com/lucide@latest"></script>
            </head>
            <body class="bg-gray-100 min-h-screen">
              <div class="container mx-auto px-4 py-8">
                <div class="mb-10 text-center">
                  <h1 class="text-3xl font-bold text-blue-800 mb-2">Nixarr Admin Dashboard</h1>
                  <p class="text-gray-600">Your media server management hub</p>
                </div>
                
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  <!-- Jellyfin -->
                  <a href="http://jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-blue-700 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Jellyfin</span>
                        <i data-lucide="film" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Media Server</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-blue-100 text-blue-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Sonarr -->
                  <a href="http://sonarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-green-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Sonarr</span>
                        <i data-lucide="tv" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">TV Shows Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-green-100 text-green-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Radarr -->
                  <a href="http://radarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-red-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Radarr</span>
                        <i data-lucide="camera" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Movies Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-red-100 text-red-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Lidarr -->
                  <a href="http://lidarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-purple-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Lidarr</span>
                        <i data-lucide="music" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Music Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-purple-100 text-purple-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Readarr -->
                  <a href="http://readarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-yellow-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Readarr</span>
                        <i data-lucide="book-open" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Book Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-yellow-100 text-yellow-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Prowlarr -->
                  <a href="http://prowlarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-indigo-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Prowlarr</span>
                        <i data-lucide="search" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Indexer Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-indigo-100 text-indigo-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Bazarr -->
                  <a href="http://bazarr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-teal-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Bazarr</span>
                        <i data-lucide="message-square" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Subtitle Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-teal-100 text-teal-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Jellyseerr -->
                  <a href="http://jellyseerr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-pink-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Jellyseerr</span>
                        <i data-lucide="list-plus" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Request Management</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-pink-100 text-pink-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Unmanic -->
                  <a href="http://unmanic.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-orange-500 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Transcoding</span>
                        <i data-lucide="file-video-2" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Video Library Optimizer</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-orange-100 text-orange-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Flaresolverr -->
                  <a href="http://flaresolverr.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-cyan-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Flaresolverr</span>
                        <i data-lucide="shield-check" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Cloudflare Bypass</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-cyan-100 text-cyan-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- Transmission -->
                  <a href="http://transmission.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-orange-600 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">Transmission</span>
                        <i data-lucide="download" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">BitTorrent Client</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-orange-100 text-orange-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                  
                  <!-- SABnzbd -->
                  <a href="http://sabnzbd.jellyfin.local" class="block">
                    <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300 h-full">
                      <div class="bg-gray-700 p-4 text-white flex items-center justify-between">
                        <span class="font-medium">SABnzbd</span>
                        <i data-lucide="inbox" class="h-5 w-5"></i>
                      </div>
                      <div class="p-4">
                        <p class="text-gray-600 text-sm">Usenet Client</p>
                        <div class="mt-4 flex justify-end">
                          <span class="text-xs inline-flex items-center font-medium rounded-full px-2.5 py-0.5 bg-gray-100 text-gray-800">
                            <i data-lucide="external-link" class="h-3 w-3 mr-1"></i> Open
                          </span>
                        </div>
                      </div>
                    </div>
                  </a>
                </div>
                
                <footer class="mt-12 text-center text-gray-500 text-sm">
                  <p>&copy; Nixarr Media Server Suite</p>
                </footer>
              </div>
              
              <!-- Initialize Lucide Icons -->
              <script>
                lucide.createIcons();
              </script>
            </body>
            </html>
          '';
        };
      };
    };
  };

  # Add hosts entries for local development
  networking.extraHosts = ''
    127.0.0.1 jellyfin.local
    127.0.0.1 sonarr.jellyfin.local
    127.0.0.1 radarr.jellyfin.local
    127.0.0.1 lidarr.jellyfin.local
    127.0.0.1 readarr.jellyfin.local
    127.0.0.1 prowlarr.jellyfin.local
    127.0.0.1 bazarr.jellyfin.local
    127.0.0.1 jellyseerr.jellyfin.local
    127.0.0.1 transmission.jellyfin.local
    127.0.0.1 sabnzbd.jellyfin.local
    127.0.0.1 admin.jellyfin.local
    127.0.0.1 flaresolverr.jellyfin.local
  '';
}
