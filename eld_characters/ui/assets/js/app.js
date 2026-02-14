const wrap = document.getElementById("wrap");
const list = document.getElementById("list");
const err = document.getElementById("error");
const first = document.getElementById("first");
const last = document.getElementById("last");

const createBox = document.getElementById("createBox");
const creatorBox = document.getElementById("creatorBox");
const preset = document.getElementById("preset");

let currentCharId = null;

const presets = {
  male_1:   { model: "mp_male" },
  male_2:   { model: "mp_male" },
  female_1: { model: "mp_female" },
  female_2: { model: "mp_female" },
};

document.getElementById("btnCreate").addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/create`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ first: first.value, last: last.value })
  });
});

document.getElementById("btnFinish").addEventListener("click", () => {
  if (!currentCharId) return;

  const key = preset.value;
  const appearance = presets[key] || presets.male_1;

  fetch(`https://${GetParentResourceName()}/creatorFinish`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ charId: currentCharId, appearance: JSON.stringify(appearance) })
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

  const slots = payload?.slots ?? 1;
  const chars = payload?.chars ?? [];

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

    const left = document.createElement("div");
    left.innerHTML = `<b>#${c.id}</b> ${c.first_name} ${c.last_name}`;

    const btn = document.createElement("button");
    btn.textContent = "Select";
    btn.addEventListener("click", () => {
      fetch(`https://${GetParentResourceName()}/select`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ charId: c.id })
      });
    });

    row.appendChild(left);
    row.appendChild(btn);
    list.appendChild(row);
  });
}

window.addEventListener("message", (e) => {
  const d = e.data || {};

  if (d.action === "open") {
    wrap.classList.remove("hidden");
    creatorBox.classList.add("hidden");
    createBox.classList.remove("hidden");
    currentCharId = null;
  }

  if (d.action === "close") {
    wrap.classList.add("hidden");
    currentCharId = null;
  }

  if (d.action === "list") {
    render(d.data || {});
  }

  if (d.action === "error") {
    showError(d.message || "Error");
  }

  if (d.action === "creator_open") {
    wrap.classList.remove("hidden");
    createBox.classList.add("hidden");
    creatorBox.classList.remove("hidden");
    currentCharId = d.data?.charId ?? null;
    clearError();
  }
});
