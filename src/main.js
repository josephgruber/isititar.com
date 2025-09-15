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

const eightball = document.getElementById('eightball');
const img = eightball.querySelector("img");

img.addEventListener("click", () => {
    // Check if the action is already in progress. If so, return without running
    if (eightball.dataset.inProgress) {
        return;
    }

    // Set the `inProgress` flag to true to indicate the eightball  is in progress
    eightball.dataset.inProgress = true;

    // Remove any existing answer
    document.querySelectorAll("div.answer").forEach((div) => div.remove());


    // Randomized shake parameters
    const shakes = Math.floor(Math.random() * 15) + 5;      // 5–19
    const distanceX = Math.floor(Math.random() * 40) + 20;   // 20–59 px
    const distanceY = Math.floor(Math.random() * 40) + 20;   // 20–59 px
    const rotateDeg = Math.floor(Math.random() * 160) + 20; // 20-179 deg
    const totalMs = Math.floor(Math.random() * 2500) + 1000; // 1000–3499 ms

    // Compute per-iteration duration so total time ≈ totalMs
    const perIter = Math.max(40, Math.floor(totalMs / shakes));

    // Configure CSS variables for this run
    img.style.setProperty("--shake-x-distance", `${(Math.random() < 0.5 ? -1 : 1) * distanceX}px`);
    img.style.setProperty("--shake-y-distance", `${(Math.random() < 0.5 ? -1 : 1) * distanceY}px`);
    img.style.setProperty("--shake-xy-rotation", `${Math.random() < 0.5 ? -1 : 1 * rotateDeg}deg`);
    img.style.setProperty("--shake-duration", `${perIter}ms`);
    img.style.setProperty("--shake-iterations", `${shakes}`);

    // Trigger CSS animation
    img.classList.add("shaking");

    // When the shake finishes, show the answer with a CSS transition
    const onAnimEnd = () => {
        img.removeEventListener("animationend", onAnimEnd);
        img.classList.remove("shaking");

        const answer = document.createElement("div");
        answer.className = "answer";
        answer.textContent = getAnswer();
        eightball.appendChild(answer);

        // Kick off the transition on the next frame
        requestAnimationFrame(() => {
            // Two frames to ensure layout
            requestAnimationFrame(() => {
                answer.classList.add("show");
            });
        });

        // Reset inProgress after the fade-in completes
        const onTransitionEnd = (evt) => {
            answer.removeEventListener("transitionend", onTransitionEnd);
            delete eightball.dataset.inProgress;
        };
        answer.addEventListener("transitionend", onTransitionEnd);
    };

    img.addEventListener("animationend", onAnimEnd, { once: true });
});

function getAnswer() {
    // Gets a random answer from the `answers` constant
    let randomNumber = Math.floor(Math.random() * answers.length);
    let answer = answers[randomNumber];

    return answer;
}
