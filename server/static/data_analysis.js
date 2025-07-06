document.addEventListener("DOMContentLoaded", function () {
    const ctx = document.getElementById('myChart');
    let myChart;

    async function fetchData(limit, sensorType) {
    const response = await fetch(`http://192.168.49.2:31145/api/data?limit=${limit}&type=${sensorType}`);
    const data = await response.json();
    console.log(data)
    return {
        timestamp: data.map(data => data.timestamp),
        sensorValue: data.map(data => data.value),              }

    }

    async function updateChart() {
    const limit = document.getElementById('data-limit').value;
    const sensorType = document.getElementById('data-type').value;
    const { timestamp, sensorValue } = await fetchData(limit, sensorType);

    if (myChart) {
        myChart.destroy();
    }

    myChart = new Chart(ctx, {
        type: 'line',
        data: {
        labels: timestamp,
        datasets: [{
            label: `${sensorType} data`,
            data: sensorValue,
        }]
        },
        options: {
        responsive: true,
        }
    });
    }

    async function getMinMaxAvg() {
        const limit = document.getElementById("data-limit").value;
        const sensorType = document.getElementById("data-type").value;
        const response = await fetch(`http://192.168.49.2:31145/api/data/min_max?limit=${limit}&type=${sensorType}`);
        const data = await response.json();
        document.getElementById("min-value").textContent = `Min value: ${data.min}`;
        document.getElementById("max-value").textContent = `Max value: ${data.max}`;
        document.getElementById("avg-value").textContent = `Avg value: ${data.average.toFixed(2)}`;
    }

    function exportCSV() {
        const limit = document.getElementById("data-limit").value;
        const sensorType = document.getElementById("data-type").value;
    
        fetch(`http://192.168.49.2:31145/api/data/export_to_csv?limit=${limit}&type=${sensorType}`)
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok');
                return response.blob();
            })
            .then(blob => {
                const url = window.URL.createObjectURL(blob);
                const link = document.createElement("a");
                link.setAttribute("href", url);
                link.setAttribute("download", `sensor_data_${sensorType}_${limit}_records.csv`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                window.URL.revokeObjectURL(url);
            })
            .catch(error => {
                console.error("Error downloading CSV:", error);
            });
    }
    
    document.getElementById('data-type').addEventListener('change', function () {
        getMinMaxAvg();
    });

    document.getElementById('data-limit').addEventListener('change', function () {
        getMinMaxAvg();
    });

    document.getElementById('data-limit').addEventListener('change', function () {
        updateChart();
    });

    document.getElementById('data-type').addEventListener('change', function () {
        updateChart();
    });

    document.getElementById('export-csv').addEventListener('click', function () {
        exportCSV();
    }
    );
    updateChart();
    getMinMaxAvg();

});