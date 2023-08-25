const answers = [
    "¯\\_(ツ)_/¯",
    "I'm a magic 8 ball, not a lawyer",
    "It is certain",
    "Without a doubt",
    "Yes definitely",
    "As I see it, yes",
    "Most likely",
    "Yes",
    "No",
    "Unlikely",
    "How do I know?",
    "Signs point to yes",
    "Reply hazy try again",
    "Ask again later",
    "Cannot predict now",
    "Don’t count on it",
    "Outlook not so good",
    "My sources say no",
    "Very doubtful",
    "Who honestly knows",
    "LOL",
    "Ask Elon"
];

$(document).on("click", "div.answer, #eightball img", function () {
    $("div.answer").remove();

    let directions = ["up", "left"];
    let shakes = Math.floor(Math.random() * 15) + 5;
    let distance = Math.floor(Math.random() * 40) + 20;
    let speed = Math.floor(Math.random() * 2500) + 1000;
    let direction = directions[Math.floor(Math.random() * directions.length)];

    $("#eightball img").effect("shake", { direction: direction, times: shakes, distance: distance }, speed);

    $("#eightball img")
        .promise()
        .done(function () {
            let answer = getAnswer();
            let item = $(`<div class="answer">${answer}</div>`).hide();

            $("#eightball").append(item);
            item.fadeIn(2500);
        });
});

function getAnswer() {
    let randomNumber = Math.floor(Math.random() * answers.length);
    let answer = answers[randomNumber];

    return answer;
}
