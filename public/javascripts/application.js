// This file is automatically included by javascript_include_tag :defaults
var viewportwidth;
var viewportheight;
 
 // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
 
 if (typeof window.innerWidth != 'undefined')
 {
      viewportwidth = window.innerWidth,
      viewportheight = window.innerHeight
 }
 
// IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)

 else if (typeof document.documentElement != 'undefined'
     && typeof document.documentElement.clientWidth !=
     'undefined' && document.documentElement.clientWidth != 0)
 {
       viewportwidth = document.documentElement.clientWidth,
       viewportheight = document.documentElement.clientHeight
 }
 
 // older versions of IE
 
 else
 {
       viewportwidth = document.getElementsByTagName('body')[0].clientWidth,
       viewportheight = document.getElementsByTagName('body')[0].clientHeight
 }


function mark_for_destroy(element) {
	$(element).next('.should_destroy').value = 1;
	$(element).up('.image').hide();
	
}
function textCounter(field, cntfield, maxlimit){
    if (field.value.length > maxlimit) 
        field.value = field.value.substring(0, maxlimit);
    else 
        cntfield.value = maxlimit - field.value.length;
}
function popup(u_id){
	document.getElementById('light_' + u_id).style.display='block';
	document.getElementById('fade').style.display='block';
}
function popup_hide(u_id){
	document.getElementById('light_' + u_id).style.display='none';
	document.getElementById('fade').style.display='none';
}

//Google map functions

var map;
var currentFocus=false;
var loggin=false;

function focusPoint(id, lat, lng, current_address){
	var markerHTML = '<div><h3>Address: </h3><p>' + current_address +'</p></div>'; 
	if (currentFocus) {
		Element.removeClassName("sidebar-item"+currentFocus,"current");
	}
	map.clearOverlays();
	Element.addClassName("sidebar-item"+id,"current");
	//Element.removeClassName('body', 'sidebar-on');
	currentFocus=id;
	map.clearOverlays();
	var latlng = new GLatLng(lat, lng);
	var marker = new GMarker(latlng);
	GEvent.addListener(marker, 'click', function(){
		marker.openInfoWindowHtml(markerHTML, {maxWidth:30});
	});
	map.addOverlay(marker);
	map.setCenter(latlng, 8);
	map.openInfoWindowHtml( marker.getLatLng(), markerHTML, {maxWidth: 30, pixelOffset: new
	GSize(0,-30)});
}

function createMarker(point, image_path, marker_id, marker_title, desc) {
  var picIcon = new GIcon(G_DEFAULT_ICON); 
  picIcon.imageOut = image_path;
  picIcon.image = picIcon.imageOut;
  picIcon.iconSize = new GSize(25, 25);
  picIcon.iconAnchor = new GPoint(0,15);
  picIcon.iconInfoWindowAnchor = new GPoint(0,15);
  picIcon.shadowSize = new GSize(25, 25);
  picIcon.shadow = image_path;
  picIcon.transparent = image_path;
  // Set up our GMarkerOptions object
  markerOptions = {id:marker_id, title:marker_title, icon:picIcon };
  var marker = new GMarker(point, markerOptions);
  GEvent.addListener(marker, "click", function() {
    marker.openInfoWindowHtml(desc);
  });
  //GEvent.addListener(marker, 'mouseover', function(){marker.setImage(marker.getIcon().imageOver);});
  //GEvent.addListener(marker, 'mouseout', function(){marker.setImage(marker.getIcon().imageOut);});
  //GEvent.addListener(marker, 'mouseover', function(){document.getElementById('mtgt_' + marker_id).setStyle('border','1px solid #000000');});
  //GEvent.addListener(marker, 'mouseout', function(){document.getElementById('mtgt_'+ marker_id).setStyle('border: none;z-index: -1#{rand(123456789)};');});
  return marker;
}

function addM(id, lat, lng, photo_path, title, info){
	var markers = new Array();
	for (var i = 0; i < id.length; i++) {
		var latlng = new GLatLng(lat[i], lng[i]);
		var description = info[i];
		var marker_title = title[i];
		var marker_id = "marker_" + id[i];
		var photo = photo_path[i];
		var marker = createMarker(latlng, photo, marker_id, marker_title, description);
		map.addOverlay(marker);
		//GEvent.addListener(marker, 'mouseover', function(){marker.setImage(marker.getIcon().imageOver);});
      	//GEvent.addListener(marker, 'mouseout', function(){marker.setImage(marker.getIcon().imageOut);});
		//markers.push(createMarker(latlng, photo, marker_id, marker_title, description));
  	} 
	
	//var mgr = new MarkerManager(map);
	//mgr.addMarkers(markers,0,17); 
	//mgr.refresh();
}
function fullscreen(){
	var center = getCenter();
	
}
function calculate_route(lat1, lng1, lat2, lng2){
	var directionsPanel = document.getElementById("results");
	var directions = new GDirections(map, directionsPanel);
	//Create our two GLatLng objects to start and destination
	var start = new GLatLng(lat1, lng1);
	var destination = new GLatLng(lat2, lng2);
		
	//Create an array of two GLatLng Objects
	var arrLocation = new Array(2);
	arrLocation[0] = start;
	arrLocation[1] = destination;
		
	//Clear the map from any old information
	directions.clear();
	map.clearOverlays();	
	//Load the map and directions from the specified waypoints
	directions.loadFromWaypoints(arrLocation);
}

function initialize(log) {
	if (viewportheight) {
		document.getElementById("map").style.height = (viewportheight-98) + "px";
		document.getElementById("map-wrapper").style.height = (viewportheight-98) + "px";
		document.getElementById("sidebar").style.height = (viewportheight-98) + "px";
	}
	Element.addClassName("body","sidebar-on");	
	
	 if (GBrowserIsCompatible() && !log) {
        map = new GMap2(document.getElementById("map"));
        map.setUIToDefault();
		map.setCenter(new GLatLng(50, 10), 5);
		
		
      }
	  else if (GBrowserIsCompatible() && log){
	  	map = new GMap2(document.getElementById("map"));
		map.setUIToDefault();
	  	map.setCenter(new GLatLng(50, 10), 5);
		map.setMapType(G_PHYSICAL_MAP);
	  }
}
function testf(){
	alert("dsdsadsa");
}

//window.onload = init();
window.onunload = GUnload;