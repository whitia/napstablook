/**
 * @function checkSelectFile
 * @description Check if import file is selected
 */
const checkSelectFile = () => {
  document.querySelector('#submit').addEventListener('click', event => {
    const fileName = document.querySelector('#file_name');
    if (fileName.value == '') {
      alert('Nothing selected a file.');
      fileName.focus();
      event.preventDefault();
      event.stopPropagation();
    }
  });
}

/**
 * @function setFileName
 * @param {*} element File field
 * @description Set selected import file to value of textbox field
 */
const setFileName = element => {
  document.querySelector('#file_name').value = element.files[0].name;
}

/**
 * @function updateRatio
 * @description Update ratio with data received asynchronously from controller
 */
const updateRatios = () => {
  document.addEventListener('ajax:success', event => {
    const data = event.detail[0];
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
        }

        document.querySelector('#' + after.category + '_Purchase').innerText = after.purchase;
        document.querySelector('#' + after.category + '_Valuation').innerText = after.valuation;
        document.querySelector('#' + after.category + '_Real').innerText = after.real;
        document.querySelector('#' + after.category + '_Difference').innerText = after.difference;
        if (after.difference < 0) {
          document.querySelector('#' + after.category + '_Difference').classList.add('text-red');
        } else {
          document.querySelector('#' + after.category + '_Difference').classList.remove('text-red');
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

document.addEventListener('turbolinks:load', event => {
  checkSelectFile();
  document.querySelector('#file').addEventListener('change', event => {
    setFileName(event.target);
  });
  updateRatios();
});