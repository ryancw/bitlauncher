$('#create-btn').click(function(evt) {
  evt.preventDefault();
  create();
  $('#create-btn').prop('disabled', true);
});

$('#stop-btn').click(function(evt) {
  evt.preventDefault();
  stop_instance();
  $('#stop-btn').prop('disabled', true);
});

var create = function() {
  var access = $('#access-key').val();
  var secret = $('#secret-key').val();
  $.post(
    "/create",
    {access: access, secret: secret},
    function(data) {
      if (data.error) {
        $('#stack-name').text(data.error);
      } else {
        $('#stack-name').text(data.stack_name);
        setTimeout(checkStatus, 1000);
      }
    });
}

var stop_instance = function() {
  var access = $('#access-key').val();
  var secret = $('#secret-key').val();
  var stack_name = $('#stack-name').text();
  $.post(
    "/stop",
    {access: access, secret: secret, stack_name: stack_name},
    function(data) {
      if (data.error) {
        $('#stack-name').text(data.error);
      } else {
        $('#stack-name').text(data.stack_name);
      }
    });
}

var checkStatus = function() {
  var access = $('#access-key').val();
  var secret = $('#secret-key').val();
  var stack_name = $('#stack-name').text();
  $.get(
    '/status',
    {access: access, secret: secret, stack_name: stack_name},
    function(data) {
      if (data.status != 'CREATE_COMPLETE') {
        $("#status").text(data.status);
        $("#status").append("<img src=ajax-loader.gif></img>")
        setTimeout(checkStatus, 3000);
      } else {
        $("#status").text(data.status);
        $("#app-url").append("<a target='_blank' href=\""+data.url+"\">" + data.url + "</a>");
        $("#stop-btn").show();
      }
    });
};
