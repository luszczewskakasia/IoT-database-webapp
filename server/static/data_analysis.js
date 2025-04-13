document.addEventListener("DOMContentLoaded", function () {
    const ctx = document.getElementById('myChart');
    let myChart;

    async function fetchData(limit, sensorType) {
    const response = await fetch(`http://127.0.0.1:7000/api/data?limit=${limit}&type=${sensorType}`);
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

    function exportCSV() {
        const limit = document.getElementById("data-limit").value;
        const sensorType = document.getElementById("data-type").value;

        fetch(`http://127.0.0.1:8000/api/data/export_to_csv`)
            .then(response => response.json())
            .then(({ data }) => {
                let csvContent = "Timestamp,Value\n";
                data.forEach(entry => {
                    csvContent += `${entry.timestamp},${entry.value}\n`;
                });

                const blob = new Blob([csvContent], { type: "text/csv" });
                const link = document.createElement("a");
                link.href = URL.createObjectURL(blob);
                link.download = `${sensorType}_data.csv`;
                link.click();
            });
    }

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

});