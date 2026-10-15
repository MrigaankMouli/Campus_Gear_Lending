import { ethers } from "https://cdnjs.cloudflare.com/ajax/libs/ethers/6.7.0/ethers.min.js";
import { CONTRACT_ADDRESS, EXPECTED_CHAIN_ID } from "./config.js";

const ABI = [
  "function custodian() view returns (address)",
  "function itemCount() view returns (uint256)",
  "function loanCount() view returns (uint256)",
  "function getItem(uint256) view returns (tuple(string name,bool enabled,uint256 currentLoanId))",
  "function getLoan(uint256) view returns (tuple(uint256 itemId,address borrower,uint256 dueAt,uint8 status))",
  "function addItem(string) returns (uint256)",
  "function setItemEnabled(uint256,bool)",
  "function requestLoan(uint256,uint256) returns (uint256)",
  "function approveLoan(uint256)",
  "function cancelRequest(uint256)",
  "function markReturned(uint256)",
  "function confirmReturn(uint256)"
];

const $ = (id) => document.getElementById(id);
const statusNames = ["Pending", "Active", "Return pending", "Closed", "Cancelled"];
let provider, signer, contract, account, custodian;
let busy = false;

function notice(message, error = false) {
  $("notice").textContent = message;
  $("notice").classList.toggle("error", error);
}
function short(address) { return `${address.slice(0, 6)}…${address.slice(-4)}`; }
function el(tag, cls, text) {
  const node = document.createElement(tag);
  if (cls) node.className = cls;
  if (text !== undefined) node.textContent = text;
  return node;
}
function action(label, handler) {
  const btn = el("button", "", label);
  btn.type = "button";
  btn.disabled = busy;
  btn.addEventListener("click", handler);
  return btn;
}
function errorMessage(error) {
  if (error?.code === 4001 || error?.code === "ACTION_REJECTED") return "Wallet request rejected.";
  return error?.reason || error?.info?.error?.message || error?.shortMessage || error?.message || "Unknown error";
}
async function requireNetwork() {
  const network = await provider.getNetwork();
  if (network.chainId !== BigInt(EXPECTED_CHAIN_ID)) throw new Error(`Wrong network. Switch MetaMask to chain ID ${EXPECTED_CHAIN_ID}.`);
  if (!(await provider.getCode(CONTRACT_ADDRESS)) || await provider.getCode(CONTRACT_ADDRESS) === "0x") throw new Error("No contract at that address on this network.");
}
async function connect() {
  try {
    if (!window.ethereum) throw new Error("Install MetaMask and open this page in its browser.");
    if (!ethers.isAddress(CONTRACT_ADDRESS)) throw new Error("Set a valid deployed address in frontend/config.js first.");
    await window.ethereum.request({ method: "eth_requestAccounts" });
    provider = new ethers.BrowserProvider(window.ethereum);
    await requireNetwork();
    signer = await provider.getSigner();
    account = await signer.getAddress();
    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
    custodian = await contract.custodian();
    $("connectionText").textContent = `${short(account)} · ${account.toLowerCase() === custodian.toLowerCase() ? "Custodian" : "Borrower"}`;
    $("networkText").textContent = `Chain ID ${EXPECTED_CHAIN_ID} · Contract ${short(CONTRACT_ADDRESS)}`;
    $("refreshBtn").disabled = false;
    notice("Connected. Blockchain records loaded below.");
    await refresh();
  } catch (err) { notice(errorMessage(err), true); }
}
async function send(label, operation) {
  if (busy) return;
  try {
    if (!contract) throw new Error("Connect MetaMask first.");
    await requireNetwork();
    busy = true;
    notice(`${label}: confirm in MetaMask…`);
    const tx = await operation();
    notice(`${label}: waiting for confirmation (${tx.hash})`);
    const receipt = await tx.wait();
    if (receipt.status !== 1) throw new Error("Transaction reverted.");
    notice(`${label} confirmed. Transaction: ${tx.hash}`);
    await refresh();
  } catch (err) { notice(errorMessage(err), true); }
  finally { busy = false; }
}
async function refresh() {
  if (!contract) return;
  try {
    await requireNetwork();
    const [ic, lc] = await Promise.all([contract.itemCount(), contract.loanCount()]);
    const items = await Promise.all(Array.from({length:Number(ic)}, (_,i) => contract.getItem(i+1)));
    const loans = await Promise.all(Array.from({length:Number(lc)}, (_,i) => contract.getLoan(i+1)));
    $("itemTotal").textContent = `${ic} items`;
    $("loanTotal").textContent = `${lc} loans`;
    const itemList = $("itemList"), loanList = $("loanList"), selector = $("itemSelect");
    itemList.replaceChildren(); loanList.replaceChildren(); selector.replaceChildren(el("option", "", "Choose an item"));
    selector.firstChild.value = "";
    itemList.classList.toggle("empty", items.length === 0);
    loanList.classList.toggle("empty", loans.length === 0);
    if (!items.length) itemList.append(el("div", "", "No equipment has been added yet."));
    if (!loans.length) loanList.append(el("div", "", "No loans recorded yet."));
    items.forEach((item,i) => {
      const id = i+1, available = item.enabled && item.currentLoanId === 0n;
      const row = el("article", "row"), top = el("div", "rowtop"), acts = el("div", "rowActions");
      top.append(el("strong", "", `#${id} ${item.name}`), el("span", `tag ${available ? "" : "muted"}`, available ? "Available" : !item.enabled ? "Disabled" : "Reserved"));
      row.append(top, el("div", "detail", item.currentLoanId ? `Current loan #${item.currentLoanId}` : "No open loan"));
      if (account.toLowerCase() === custodian.toLowerCase()) acts.append(action(item.enabled ? "Disable" : "Enable", () => send("Update equipment", () => contract.setItemEnabled(id, !item.enabled))));
      if (acts.childNodes.length) row.append(acts);
      itemList.append(row);
      if (available) { const option = el("option", "", `#${id} ${item.name}`); option.value = String(id); selector.append(option); }
    });
    loans.slice().reverse().forEach((loan, reverseIndex) => {
      const id = loans.length-reverseIndex, state = Number(loan.status);
      const row = el("article", "row"), top = el("div", "rowtop"), acts = el("div", "rowActions");
      top.append(el("strong", "", `Loan #${id} · ${items[Number(loan.itemId)-1]?.name ?? `Item #${loan.itemId}`}`), el("span", `tag ${state >= 3 ? "muted" : ""}`, statusNames[state]));
      row.append(top, el("div", "detail", `Borrower ${short(loan.borrower)} · Due ${new Date(Number(loan.dueAt)*1000).toLocaleString()}`));
      const isCustodian = account.toLowerCase() === custodian.toLowerCase();
      const isBorrower = account.toLowerCase() === loan.borrower.toLowerCase();
      if (state === 0 && isCustodian) acts.append(action("Approve", () => send("Approve loan", () => contract.approveLoan(id))));
      if (state === 0 && (isCustodian || isBorrower)) acts.append(action("Cancel", () => send("Cancel request", () => contract.cancelRequest(id))));
      if (state === 1 && isBorrower) acts.append(action("Mark returned", () => send("Mark returned", () => contract.markReturned(id))));
      if (state === 2 && isCustodian) acts.append(action("Confirm return", () => send("Confirm return", () => contract.confirmReturn(id))));
      if (acts.childNodes.length) row.append(acts);
      loanList.append(row);
    });
  } catch (err) { notice(errorMessage(err), true); }
}
$("connectBtn").addEventListener("click", connect);
$("refreshBtn").addEventListener("click", refresh);
$("requestForm").addEventListener("submit", (event) => {
  event.preventDefault();
  const itemId = Number($("itemSelect").value);
  const dueAt = Math.floor(new Date($("dueAt").value).getTime()/1000);
  const seconds = dueAt - Math.floor(Date.now()/1000);
  if (!itemId || !Number.isFinite(seconds) || seconds <= 0 || seconds > 30*86400) { notice("Choose an available item and a due date within 30 days.", true); return; }
  send("Request loan", () => contract.requestLoan(itemId, dueAt));
});
$("addForm").addEventListener("submit", (event) => {
  event.preventDefault();
  const name = $("itemName").value.trim();
  if (!name || new TextEncoder().encode(name).length > 80) { notice("Enter an item name of 1 to 80 UTF-8 bytes.", true); return; }
  send("Add item", () => contract.addItem(name));
});
if (window.ethereum) {
  window.ethereum.on("accountsChanged", () => { contract = null; location.reload(); });
  window.ethereum.on("chainChanged", () => location.reload());
}
