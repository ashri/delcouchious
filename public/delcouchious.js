var toggleInfo = function() {
	$(this).find('p.document-info').slideToggle('fast');
}

var hoverConfig = {    
     sensitivity: 3,
     interval: 200,
     over: toggleInfo,
     timeout: 200,
     out: toggleInfo
};

$(document).ready(function() {
	$('#toread li').hoverIntent(hoverConfig);
	$('#tag-view li').hoverIntent(hoverConfig);
	$('article#tag-cloud ul li#cloudShowTagsItem a').bind('click', function() {
		$('article#tag-cloud ul li.hidden').css('display', 'inline-table');
		$('article#tag-cloud ul li#cloudShowTagsItem').remove();
	});
});
