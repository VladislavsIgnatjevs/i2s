

$(document).ready(function() {      

});

$(window).load(function() {
      //alert("window load occurred!");

});


$("a").focus(function() {
	var msg =  $(this).attr('rel');
	var img = $(this).find("img");
	var url = img[0].src

	var audioElement = document.createElement('audio');
        audioElement.setAttribute('src', 'http://172.19.95.100:3000/?lang=en&imgurl='+url);
        audioElement.setAttribute('autoplay', 'autoplay');
       audioElement.addEventListener("load", function() {
            audioElement.play();
        }, true);

	//loadXMLDoc();

});


function loadXMLDoc()
{
//alert("LOADXMLDOC");


$.ajax({
  type: "GET",
  url: "http://www.sounddogs.com/previews/2753/mp3/651061_SOUNDDOGS__zi.mp3",
  data: "",
  success: function(mp3_blob){ 
	//$( ".inner" ).append( ' <audio controls="controls"> <source src=http://www.sounddogs.com/previews/2753/mp3/651061_SOUNDDOGS__zi.mp3" type="audio/mp3"> </audio>')

	btoa(string);

	var audioElement = document.createElement('audio');
        audioElement.setAttribute('src', 'http://www.sounddogs.com/previews/2753/mp3/651061_SOUNDDOGS__zi.mp3');
        audioElement.setAttribute('autoplay', 'autoplay');
       audioElement.addEventListener("load", function() {
            audioElement.play();
        }, true);
	//var dsds = new window.Audio();
	//dsds.src = mp3_blob;
	//dsds.play();
	/*
	  $( ".inner" ).append( '<div id="jquery_jplayer"><a href="#" id="jplayer_play" class="jp-play" tabindex="1"></a></div>' );
          var myPlayList = [
              {name:"Effect",mp3: mp3_blob},
          ];
          $("#jquery_jplayer").jPlayer("setFile", myPlayList[0].mp3, myPlayList[0].ogg);
	var shit = $("#jquery_jplayer");
	 $("#jquery_jplayer").jPlayer("play");	

	var kldflks = mp3_blob*/
  },
  error: function(mp3){ 
	var kldflks = mp3
  },	
});
}
/*
var xmlhttp;
xmlhttp=new XMLHttpRequest();
xmlhttp.open("GET","http://www.sounddogs.com/previews/2753/mp3/651061_SOUNDDOGS__zi.mp3",true);
xmlhttp.send();
var mp3 = xmlhttp.responseXML;
*/
/*
$.ajax({
  type: "POST",
  url: "http://www.sounddogs.com/previews/2753/mp3/651061_SOUNDDOGS__zi.mp3",
  data: "",
  success: function(mp3){ 
	var kldflks = mp3
  },
  error: function(mp3){ 
	var kldflks = mp3
  },	

*/
