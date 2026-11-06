const ordersBody = document.getElementById('ordersBody');
const totalCount = document.getElementById('totalCount');
const resultCount = document.getElementById('resultCount');
const message = document.getElementById('message');
const searchInput = document.getElementById('searchInput');

let currentOrders = [];

function showMessage(text, isError = false) {
  message.textContent = text;
  message.className = isError ? 'message error' : 'message';
}

async function loadOrders(search = '') {
  try {
    const url = search.trim()
      ? `/api/orders/search?name=${encodeURIComponent(search.trim())}`
      : '/api/orders';
    const response = await fetch(url);
    if (!response.ok) throw new Error('Could not load orders.');
    currentOrders = await response.json();
    renderOrders(currentOrders);
  } catch (error) {
    ordersBody.innerHTML = `<tr><td colspan="7" class="empty">${escapeHtml(error.message)}</td></tr>`;
  }
}

function renderOrders(orders) {
  totalCount.textContent = currentOrders.length;
  resultCount.textContent = `${orders.length} ${orders.length === 1 ? 'order' : 'orders'} shown`;
  if (orders.length === 0) {
    ordersBody.innerHTML = '<tr><td colspan="7" class="empty">No matching orders found.</td></tr>';
    return;
  }

  ordersBody.innerHTML = orders.map((order, index) => `
    <tr>
      <td>${index + 1}</td>
      <td class="item-code">${escapeHtml(order.Item)}</td>
      <td>${escapeHtml(order.ItemName)}</td>
      <td>${order.Quantity}</td>
      <td class="price">${Number(order.Price).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</td>
      <td>${escapeHtml(order.Currency)}</td>
      <td><button class="delete-button" data-item="${encodeURIComponent(order.Item)}">Delete</button></td>
    </tr>
  `).join('');
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, character => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[character]);
}

document.getElementById('orderForm').addEventListener('submit', async event => {
  event.preventDefault();
  const order = {
    Item: document.getElementById('item').value.trim(),
    ItemName: document.getElementById('itemName').value.trim(),
    Price: Number(document.getElementById('price').value),
    Quantity: Number(document.getElementById('quantity').value),
    Currency: document.getElementById('currency').value
  };

  try {
    const response = await fetch('/api/orders', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(order)
    });
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Unable to add order.');
    event.target.reset();
    document.getElementById('currency').value = 'USD';
    searchInput.value = '';
    showMessage(result.message);
    await loadOrders();
  } catch (error) {
    showMessage(error.message, true);
  }
});

ordersBody.addEventListener('click', async event => {
  const button = event.target.closest('.delete-button');
  if (!button) return;
  const item = decodeURIComponent(button.dataset.item);
  if (!confirm(`Delete order ${item}?`)) return;

  try {
    const response = await fetch(`/api/orders/${encodeURIComponent(item)}`, {method: 'DELETE'});
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Unable to delete order.');
    showMessage(result.message);
    await loadOrders(searchInput.value);
  } catch (error) {
    showMessage(error.message, true);
  }
});

let searchTimer;
searchInput.addEventListener('input', () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(() => loadOrders(searchInput.value), 200);
});

document.getElementById('clearSearch').addEventListener('click', () => {
  searchInput.value = '';
  loadOrders();
});

loadOrders();
