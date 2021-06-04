/**
 * @function onTablesorterReady
 * @description Ready Tablesorter Plugin
 */
const onTablesorterReady = () => {
  $('.list-of-invest').tablesorter({
    sortReset: true,
    sortInitialOrder: 'desc',
    headers: {
      5: { sorter: false },
    }
  });
  $('.list-of-ratio').tablesorter({
    sortReset: true,
    sortInitialOrder: 'desc',
    headers: {
      3: { sorter: false },
      5: { sorter: false },
    }
  });
}

/**
 * @function setFileName
 * @param {*} element File field
 * @description Set selected import file to value of textbox field
 */
 const setFileName = () => {
  document.querySelector('#file').addEventListener('change', e => {
    document.querySelector('#file_name').value = e.target.files[0].name;
  });
}

function getExtension(filename) {
  var parts = filename.split('.');
  return parts[parts.length - 1];
}

/**
 * @function checkFile
 * @description Check if a file is selected and it type is csv
 */
const checkFile = () => {
  document.querySelector('#submit').addEventListener('click', e => {
    const file = document.querySelector('#file');

    // If a file is selected
    if (!file.value) {
      setErrorMessage('Nothing a selected file');
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
    
    // If a file type is csv
    const ext = getExtension(file.value);
    if (ext.toLowerCase() != 'csv') {
      setErrorMessage('Invalid file type of a selected');
      e.preventDefault();
      e.stopPropagation();
      return false;
    }

    overlay.textContent = 'Now importing the file...';
    document.querySelector('#overlay').style.filter = 'opacity(1)';
    document.querySelector('#overlay').style.visibility = 'visible';
  });
}

/**
 * @function updateRatio
 * @description Update ratio with data received asynchronously from controller
 */
const updateRatios = () => {
  document.addEventListener('ajax:success', e => {
    const data = e.detail[0];
    const before = data.before;
    const after = data.after;
    const realPieChart = Chartkick.charts['real-pie-chart'];
    const idealPieChart = Chartkick.charts['ideal-pie-chart'];
    
    switch (data.event) {
      case 'Category':
        if (before.category) {
          document.querySelector('#' + before.category + '_Purchase').innerText = before.purchase;
          document.querySelector('#' + before.category + '_Valuation').innerText = before.valuation;
          document.querySelector('#' + before.category + '_Real').innerText = before.real;
          document.querySelector('#' + before.category + '_Difference').innerText = before.difference;
          if (before.difference < 0) {
            document.querySelector('#' + before.category + '_Difference').classList.add('text-red');
          } else {
            document.querySelector('#' + before.category + '_Difference').classList.remove('text-red');
          }
        } else {
          document.querySelector('#' + after.category + '_Purchase').innerText = after.purchase;
          document.querySelector('#' + after.category + '_Valuation').innerText = after.valuation;
          document.querySelector('#' + after.category + '_Real').innerText = after.real;
          document.querySelector('#' + after.category + '_Difference').innerText = after.difference;
          if (after.difference < 0) {
            document.querySelector('#' + after.category + '_Difference').classList.add('text-red');
          } else {
            document.querySelector('#' + after.category + '_Difference').classList.remove('text-red');
          }
        }

        realPieChart.updateData(data.ratio.real);
        idealPieChart.updateData(data.ratio.ideal);
        break;
      
      case 'Increase':
        document.querySelector('#' + before.category + '_Valuation').innerText = before.valuation;

        Object.keys(data.ratio.real).forEach(category => {
          const real = data.ratio.real[category];
          const difference = Math.round((real - data.ratio.ideal[category]) * 1000) / 1000;

          document.querySelector('#' + category + '_Real').innerText = real;
          document.querySelector('#' + category + '_Difference').innerText = difference;
          if (difference < 0) {
            document.querySelector('#' + category + '_Difference').classList.add('text-red');
          } else {
            document.querySelector('#' + category + '_Difference').classList.remove('text-red');
          }
        });

        realPieChart.updateData(data.ratio.real);
        break;

      case 'Ratio':
        const difference = document.querySelector('#' + data.category + '_Real').innerText - data.value;
        document.querySelector('#' + data.category + '_Difference').innerText = Math.round(difference * 1000) / 1000;
        if (difference < 0) {
          document.querySelector('#' + data.category + '_Difference').classList.add('text-red');
        } else {
          document.querySelector('#' + data.category + '_Difference').classList.remove('text-red');
        }

        idealPieChart.updateData(data.ideal);
        break;

      default:
        break;
    }
  })
}

function preventDefaults (e) {
  e.preventDefault();
  e.stopPropagation();
}

function enabled (e) {
  this.target.style.filter = 'opacity(1)';
  this.target.style.visibility = 'visible';
}

function disabled (e) {
  this.target.style.filter = 'opacity(0)';
  this.target.style.visibility = 'hidden';
}

function setErrorMessage (message) {
  let messages = document.createElement('p');
  messages.id = 'import-error';
  messages.textContent = message;

  const importFile = document.querySelector('#import-file');
  if (importFile.lastChild) {
    importFile.lastChild.remove();
  }
  importFile.appendChild(messages);
}

function handleDrop (e) {
  // If a file type is csv
  const ext = getExtension(e.dataTransfer.files[0].name);
  if (ext.toLowerCase() != 'csv') {
    e.preventDefault();
    e.stopPropagation();

    document.querySelector('#overlay').style.filter = 'opacity(0)';
    document.querySelector('#overlay').style.visibility = 'hidden';

    setErrorMessage('Invalid file type');
    return false;
  }

  overlay.textContent = 'Now importing the file...';

  let formData = new FormData();
  formData.append('file', e.dataTransfer.files[0]);

  let xhr = new XMLHttpRequest();
  xhr.onreadystatechange = () => {
    if (xhr.readyState == 4) {
      switch (xhr.status) {
        case 200:
          location.reload();
          break;
        case 500:
          document.querySelector('#overlay').style.filter = 'opacity(0)';
          document.querySelector('#overlay').style.visibility = 'hidden';
          setErrorMessage(JSON.parse(xhr.responseText)['alert']);
          break;
        default:
          break;
      }
    }
  }
  xhr.open('POST', '/funds/import');

  const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
  xhr.setRequestHeader('X-CSRF-Token', token);
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

  xhr.send(formData);
}

/**
 * @function acceptDragDrop
 * @description Accept CSV file to import on window with drag'n'drop
 */
const acceptDragDrop = () => {
  const overlay = document.querySelector('#overlay');

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    overlay.addEventListener(eventName, preventDefaults, false);
  });  

  window.addEventListener('dragenter', { handleEvent: enabled, target: overlay });
  overlay.addEventListener('dragleave', { handleEvent: disabled, target: overlay });
  overlay.addEventListener('drop', { handleEvent: handleDrop, target: overlay });
}

document.addEventListener('turbolinks:load', e => {
  // Vendor scripts
  onTablesorterReady();

  setFileName();
  checkFile();
  updateRatios();
  acceptDragDrop();
});