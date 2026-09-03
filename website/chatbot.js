const chatbotButton = document.getElementById("chatbot-button");
const chatbotWindow = document.getElementById("chatbot-window");
const chatbotClose = document.getElementById("chatbot-close");
const chatbotMessages = document.getElementById("chatbot-messages");
const chatbotInput = document.getElementById("chatbot-input");
const chatbotSend = document.getElementById("chatbot-send");

let typingElement = null;
let isProcessing = false;

function getCurrentPage() {
  const pathname = window.location.pathname.toLowerCase().replace(/\/+$/, "");
  const pageName = pathname.split("/").pop();

  const pages = {
    "": "Home",
    "index.html": "Home",
    "about.html": "About",
    "platform.html": "Platform",
    "patients.html": "Patients",
    "families.html": "Families",
    "care-teams.html": "Care Teams",
    "resources.html": "Resources",
  };

  return pages[pageName] || "Home";
}

if (chatbotButton) {
  chatbotButton.addEventListener("click", function () {
    chatbotWindow.classList.toggle("open");
  });
}

if (chatbotClose) {
  chatbotClose.addEventListener("click", function () {
    chatbotWindow.classList.remove("open");
  });
}

if (chatbotSend) {
  chatbotSend.addEventListener("click", sendMessage);
}

if (chatbotInput) {
  chatbotInput.addEventListener("input", autoResizeInput);

  chatbotInput.addEventListener("keydown", function (event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  });
}

function autoResizeInput() {
  const maxHeight = 96;

  chatbotInput.style.height = "auto";
  chatbotInput.style.height = Math.min(chatbotInput.scrollHeight, maxHeight) + "px";
  chatbotInput.style.overflowY = chatbotInput.scrollHeight > maxHeight ? "auto" : "hidden";
}

function resetInputSize() {
  chatbotInput.style.height = "";
  chatbotInput.style.overflowY = "hidden";
}

function addUserMessage(text) {
  const userMessage = document.createElement("div");
  userMessage.className = "user-message";
  userMessage.dir = "auto";
  userMessage.textContent = text;
  chatbotMessages.appendChild(userMessage);
  scrollToBottom();
}

function addAssistantMessage(text) {
  const assistantMessage = document.createElement("div");
  assistantMessage.className = "assistant-message";
  assistantMessage.dir = "auto";
  assistantMessage.textContent = formatReply(text);
  chatbotMessages.appendChild(assistantMessage);
  scrollToBottom();
}

function showTypingIndicator() {
  hideTypingIndicator();

  typingElement = document.createElement("div");
  typingElement.className = "typing-message";
  typingElement.innerHTML = `
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
        <span class="typing-dot"></span>
    `;

  chatbotMessages.appendChild(typingElement);
  scrollToBottom();
}

function hideTypingIndicator() {
  if (typingElement) {
    typingElement.remove();
    typingElement = null;
  }
}

function scrollToBottom() {
  chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
}

function formatReply(text) {
  if (!text) return "";

  return text
    .replace(/\*\*/g, "")
    .replace(/###/g, "")
    .replace(/##/g, "")
    .replace(/#/g, "")
    .trim();
}

async function sendMessage() {
  if (isProcessing) return;

  const message = chatbotInput.value.trim();

  if (!message) return;

  isProcessing = true;
  chatbotSend.disabled = true;

  addUserMessage(message);
  chatbotInput.value = "";
  resetInputSize();

  showTypingIndicator();

  try {
    const response = await fetch("http://127.0.0.1:8081/chatbot.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: message,
        currentPage: getCurrentPage(),
      }),
    });

    const data = await response.json().catch(function () {
      return {};
    });

    if (data.reply) {
      addAssistantMessage(data.reply);
    } else {
      addAssistantMessage("Sorry, the NeuroBridge Assistant could not process your request. Please try again.");
    }
  } catch (error) {
    addAssistantMessage("Sorry, the NeuroBridge Assistant could not process your request. Please try again.");
  } finally {
    hideTypingIndicator();
    isProcessing = false;
    chatbotSend.disabled = false;
  }
}
