(function ($) {
  $(document).ready(function(){
    // Google Maps
    if (typeof google === 'object' && typeof google.maps === 'object') {
      function initMap(mapEl, roadColor, landColor, lat, lng, tooltip) {

        // Specify features and elements to define styles.
        var styleArray = [
          { "featureType": "all", stylers: [{ saturation: -80 }] },
          { "featureType": "water", "elementType": "geometry.fill", "stylers": [{ "color": "#bae8e4" }] },
          { "featureType": "poi", "elementType": "geometry", "stylers": [{ "visibility": "off" }] },
          { "featureType": "landscape", "elementType": "geometry", "stylers": [{ "color": "#fff" }] },
          { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
          { "featureType": "administrative", "stylers": [{ "visibility": "off" }] },
          { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": roadColor }, { "saturation": "-30" }, { "lightness": "30" }] },
          { "featureType": "road", "elementType": "geometry.stroke", "stylers": [{ "color": roadColor }, { "saturation": "-30" }, { "lightness": "30" }] },
          { "featureType": "landscape", "stylers": [{ "color": landColor }] },
          { "featureType": "transit", "stylers": [{ "color": landColor }] },
          { "elementType": "labels", "stylers": [{ "visibility": "off" }] },
          { "elementType": "labels.text", "stylers": [{ "visibility": "on" }] },
          { "elementType": "labels.icon", "stylers": [{ "visibility": "on" }] }
        ];

        // Create a map object and specify the DOM element for display.
        var map = new google.maps.Map(mapEl, {
          center: {lat: lat, lng: lng},
          scrollwheel: false,
          // Apply the map style array to the map.
          styles: styleArray,
          zoom: 11
        });

        // Create a marker and set its position.
        var marker = new google.maps.Marker({
          map: map,
          position: {lat: lat, lng: lng},
          animation: google.maps.Animation.DROP,
          title: 'Our Location!'
        });

        // Marker tooltip.
        var infowindow = new google.maps.InfoWindow({
          content: tooltip
        });
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(map,marker);
        });
        window.setTimeout(function() {
          infowindow.open(map,marker);
        }, 1000);
      }
      var lat = 37.7576793;
      var lng = -122.4;
      var roadColor = "#7CFFE6";
      var landColor = "#fafafa";
      var tooltip = "123 Main Street, San Francisco, CA 94110"
      var map = $('.google-map').first();
      if (map.length) {
        initMap(map[0], roadColor, landColor, lat, lng, tooltip);
      }
    }
  });
}( jQuery ));