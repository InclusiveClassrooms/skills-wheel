// Example requests:
// request.post('/pdf/:survey_id', );
// request.get('/pdf/:survey_id');

var Req = (function () {
  function request (method, url, payload, cb) {
    var xhr = new XMLHttpRequest();
    var payloadString = JSON.stringify(payload);

    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 && xhr.status === 200) {
        cb(JSON.parse(xhr.responseText));
      }
    };
    xhr.open(method, url);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(payloadString);
  }

  return {
    get: function (url, cb) { request('GET', url, null, cb); },
    post: function (url, payload, cb) { request('POST', url, payload, cb); }
  }
})();

