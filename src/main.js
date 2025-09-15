// Secret sauce below. Shhh, it's ITAR controlled!
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
    "Ask Elon",
    "I'm not getting involved",
    "You're going to have a FUN day",
    "I see lawyers in your future"
];

$(document).on("click", "div.answer, #eightball img", function () {
    // Check if the action is already in progress. If so, return without running
    if ($("#eightball").data('inProgress')) {
        return;
    }

    // Set the `inProgress` flag to true to indicate the eightball  is in progress
    $("#eightball").data('inProgress', true);

    console.log("Click")
    // Remove any existing answer
    $("div.answer").remove();

    // Randomize the direction, count, distance, and speed of the shake each time
    let directions = ["up", "left"];
    let shakes = Math.floor(Math.random() * 15) + 5;
    let distance = Math.floor(Math.random() * 40) + 20;
    let speed = Math.floor(Math.random() * 2500) + 1000;
    let direction = directions[Math.floor(Math.random() * directions.length)];

    // Shake the eightball!
    $("#eightball img").effect("shake", { direction: direction, times: shakes, distance: distance }, speed);

    // Return a random answer fading in over a short period
    $("#eightball img")
        .promise()
        .done(function () {
            let answer = getAnswer();
            let item = $(`<div class="answer">${answer}</div>`).hide();

            $("#eightball").append(item);
            item.fadeIn(2500);

            // Reset the `inProgress` flag to false as the action is complete
            $("#eightball").data('inProgress', false);
        });
});

function getAnswer() {
    // Gets a random answer from the `answers` constant
    let randomNumber = Math.floor(Math.random() * answers.length);
    let answer = answers[randomNumber];

    return answer;
}
