window.addEventListener('message', function(event) {
    if (event.data.type === 'playSound') {
        var audio = document.getElementById('audioPlayer');
        audio.play();
    }
});
