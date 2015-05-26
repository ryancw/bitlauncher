$('#create-btn').click(function(evt) {
  evt.preventDefault();
  create();
  checkStatus();
});

var create = function() {
  var access = $('#access-key').val();
  var secret = $('#secret-key').val();
  $.post(
    "/create",
    {access: access, secret: secret},
    function(data) {
      $('#stack-name').text(data.stack_name);
    });
}

var updateStatus = function() {

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
        setTimeout(checkStatus, 2000);
      } else {
        $("#status").text(data.status);
      }
    });
};

function status() {
  var access = $('#access-key').val();
  var secret = $('#secret-key').val();
  var stack_name = $('#stack-name').text();
  $.get(
    '/status',
    {access: access, secret: secret, stack_name: stack_name},
    function(data) {
      $("#status").text(data.status);
    });
}
