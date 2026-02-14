const wrap = document.getElementById("wrap");
const list = document.getElementById("list");
const err = document.getElementById("error");
const first = document.getElementById("first");
const last = document.getElementById("last");

document.getElementById("btnCreate").addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/create`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ first: first.value, last: last.value })
  });
});

document.getElementById("btnClose").addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
});

function showError(msg) {
  err.textContent = msg;
  err.classList.remove("hidden");
}

function clearError() {
  err.classList.add("hidden");
  err.textContent = "";
}

function render(payload) {
  clearError();
  list.innerHTML = "";

  const slots = payload.slots ?? 1;
  const chars = payload.chars ?? [];

  const info = document.createElement("p");
  info.textContent = `Slots: ${chars.length}/${slots}`;
  list.appendChild(info);

  if (!chars.length) {
    const p = document.createElement("p");
    p.textContent = "No character yet. Create one below.";
    list.appendChild(p);
    return;
  }

  chars.forEach(c => {
    const row = document.createElement("div");
    row.className = "char";
    row.innerHTML = `
      <div><b>#${c.id}</b> ${c.first_name} ${c.last_name}</div>
      <button data-id="${c.id}">Select</button>
    `;
    row.querySelector("button").addEventListener("click", () => {
      fetch(`https://${GetParentResourceName()}/select`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ charId: c.id })
      });
    });
    list.appendChild(row);
  });
}

window.addEventListener("message", (e) => {
  const d = e.data || {};
  if (d.action === "open") {
    wrap.classList.remove("hidden");
  }
  if (d.action === "close") {
    wrap.classList.add("hidden");
  }
  if (d.action === "list") {
    render(d.data || {});
  }
  if (d.action === "error") {
    showError(d.message || "Error");
  }
});
