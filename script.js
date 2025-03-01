document.addEventListener("DOMContentLoaded", () => {
    const postBtn = document.querySelector(".graffiti-btn");
    const canvas = document.querySelector(".drawing-canvas");
    const alert = document.querySelector(".update-alert");
    const graffitiWall = document.querySelector(".graffiti-wall");
    const placeholderText = "Write your appreciation message here...";

    // Initialize placeholder
    canvas.setAttribute("data-placeholder", placeholderText);
    updatePlaceholder();

    // Handle placeholder visibility
    function updatePlaceholder() {
        if (canvas.textContent.trim() === "") {
            canvas.setAttribute("data-placeholder-visible", "true");
        } else {
            canvas.removeAttribute("data-placeholder-visible");
        }
    }

    // Mobile-friendly event listeners
    canvas.addEventListener("input", updatePlaceholder);
    canvas.addEventListener("touchstart", () => canvas.removeAttribute("data-placeholder-visible"));
    canvas.addEventListener("click", () => canvas.removeAttribute("data-placeholder-visible"));
    canvas.addEventListener("blur", updatePlaceholder);

    // Mobile-optimized post handler
    postBtn.addEventListener("touchend", handlePost);
    postBtn.addEventListener("click", handlePost);

    function handlePost(e) {
        e.preventDefault();
        const text = canvas.textContent.trim();
        if (text && text !== placeholderText) {
            createMessage(text);
            showTemporaryAlert();
            resetCanvas();
        }
    }

    function createMessage(text) {
        const newMessage = document.createElement("div");
        newMessage.className = "graffiti-message";
        newMessage.style.setProperty(
            "--color",
            `hsl(${Math.random() * 360}, 70%, 60%)`
        );
        newMessage.innerHTML = `
            <div class="message-content">
                <span class="spray-effect">${text}</span>
                <div class="message-footer">
                    <span class="author">- Anonymous</span>
                    <div class="reactions">
                        <button class="react-btn">❤️ 0</button>
                    </div>
                </div>
                <div class="sticker">${getRandomSticker()}</div>
            </div>
        `;
        graffitiWall.prepend(newMessage);
    }

    // Mobile-friendly reaction handling
    graffitiWall.addEventListener("touchstart", handleReaction);
    graffitiWall.addEventListener("click", handleReaction);

    function handleReaction(e) {
        if (e.target.classList.contains("react-btn")) {
            e.preventDefault();
            const btn = e.target;
            let count = parseInt(btn.textContent.match(/\d+/)) || 0;
            btn.textContent = `❤️ ${++count}`;
        }
    }

    function getRandomSticker() {
        const stickers = ["🌟", "🎉", "🔥", "💯", "✨", "🎨", "👏"];
        return stickers[Math.floor(Math.random() * stickers.length)];
    }

    function showTemporaryAlert() {
        alert.style.display = "block";
        setTimeout(() => {
            alert.style.display = "none";
        }, 2500);
    }

    function resetCanvas() {
        canvas.textContent = "";
        canvas.blur();
        updatePlaceholder();
        // Close mobile keyboard
        document.activeElement?.blur();
    }

    // Mobile viewport hack
    document.documentElement.style.setProperty(
        "--viewport-height",
        `${window.innerHeight}px`
    );

    document.addEventListener("DOMContentLoaded", () => {
    const toolbar = document.querySelector(".toolbar");
    const canvas = document.querySelector(".drawing-canvas");

    // Handle toolbar button clicks
    toolbar.addEventListener("click", (e) => {
        const tool = e.target.getAttribute("data-tool");
        if (tool === "spray") {
            applySprayEffect(canvas);
        } else if (tool === "sticker") {
            addSticker(canvas);
        }
    });

    // Apply spray effect to text
    function applySprayEffect(element) {
        element.classList.add("spray-effect");
    }

    // Add a random sticker to the message
    function addSticker(element) {
        const stickers = ["🌟", "🎉", "🔥", "💯", "✨", "🎨", "👏"];
        const randomSticker = stickers[Math.floor(Math.random() * stickers.length)];
        element.textContent += ` ${randomSticker}`;
    }
});
});