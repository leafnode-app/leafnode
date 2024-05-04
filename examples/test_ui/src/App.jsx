import { useEffect } from "react";
import "./App.css";
import ApexCharts from "apexcharts";

const modal_types = {
  "node_setitngs": {
    "title": "Node Name",
    "desc": "Node Description"
  },
  "node_when": {
    "title": "Node When",
    "desc": "Setup the condition for when the node needs to compute against what data",
  },
  "node_do": {
    "title": "Node Do",
    "desc": "Select the details for the node execution for what it needs to do",
  },
  "node_details": {
    "title": "Node details",
    "desc": "The details on how to use the node and access or make requests against the node"
  }
}


// Column header
function Header({ title, settingCB, moreCB }) {  
  return (
    <div className="flex gap-3 p-2">
      <div className="flex-grow">{title}</div>
      {settingCB && (
        <div className="px-1 cursor-pointer" onClick={settingCB}>
          <i className="fa-solid fa-gear"></i>
        </div>
      )}
      {moreCB && (
        <div className="px-1 cursor-pointer" onClick={moreCB}>
          <i className="fa-solid fa-up-right-and-down-left-from-center"></i>
        </div>
      )}
    </div>
  );
}

// Render the blocks for the conditional UI
function WhenDo() {
  return (
    <div>
      <div className="flex flex-col p-4 h-full gap-1 justify-center flex-1">
        <div className="node_block_wrapper box_input_inset_shadow cursor-pointer">
          <pre className="px-1 text-orange-300">when :: input.message.value === "Test"</pre>
        </div>
        <div className="node_vertical_line self-center"></div>
        <div className="self-center text-zinc-600 text-xl">do</div>
        <div className="node_vertical_line self-center"></div>
        <div className="node_block_wrapper box_input_inset_shadow cursor-pointer">
          <pre className="text-blue-300">send_to_slack :: input.message.value</pre>
        </div>
      </div>
    </div>
  );
}

// The main wrapper for the columns
function MainWrapper({ children }) {
  return (
    <div className="flex flex-col md:flex-row gap-1 justify-center">
      {children}
    </div>
  );
}

function CallsStatusOverlay({ totalCalls, successfulCalls, errorCalls }) {
  return (
    <div className="status_overlay absolute z-10">
      {/* {`${totalCalls} total calls made, with ${successfulCalls} successful and ${errorCalls} resulting in errors.`} */}
      <h5
        className="
          mb-4
          font-extrabold
      text-gray-900
          text-2xl dark:text-white"
      >
        <span className="text-blue-600 dark:text-blue-300">{`${totalCalls}`}</span>{" "}
        total calls made, with{" "}
        <span className="text-green-300 dark:text-green-300">{`${successfulCalls}`}</span>{" "}
        successful and{" "}
        <span className="text-red-300 dark:text-red-300">{`${errorCalls}`}</span>{" "}
        resulting in errors.
      </h5>
    </div>
  );
}

function ColOne() {
  return (
    <div className="flex flex-col grow bg-zinc-900 rounded-lg p-4 w-full md:w-80 border border-stone-900">
      <div className="h-3/5 relative">
        {CallsStatusOverlay({
          totalCalls: 1000,
          successfulCalls: 820,
          errorCalls: 180,
        })}

        {/* Render the graph - useEffect rendering to dom */}
        <div id="chart" />
      </div>
      <div className="h-2/5 bg-grey-500 p-1">
        <div className="mb-2 border-b border-zinc-900 dark:border-zinc-900">
          <ul
            className="flex flex-wrap mb-px text-sm font-medium text-center"
            role="tablist"
          >
            <li className="me-2">
              <div className="inline-block p-4 border-b-2 rounded-t-lg">
                Logs
              </div>
            </li>
          </ul>
        </div>

        <ul className="divide-y divide-zinc-900 dark:border-zinc-900 px-2">
          <li className="py-2 sm:py-2">
            <div className="flex items-center space-x-4 rtl:space-x-reverse">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate dark:text-white">
                  Item 1
                </p>
                <p className="text-sm text-gray-500 truncate dark:text-gray-400">
                  2018-09-19T01:30:00.000Z
                </p>
              </div>
              <div className="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                <span className="bg-red-100  text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-red-700">
                  Failed
                </span>
              </div>
            </div>
          </li>
          <li className="py-2 sm:py-2">
            <div className="flex items-center space-x-4 rtl:space-x-reverse">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate dark:text-white">
                  Item 2
                </p>
                <p className="text-sm text-gray-500 truncate dark:text-gray-400">
                  2018-09-19T01:30:00.000Z
                </p>
              </div>
              <div className="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                <span className="bg-green-100 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-green-700">
                  Success
                </span>
              </div>
            </div>
          </li>
          <li className="py-2 sm:py-2 hover:bg-light-300">
            <div className="flex items-center space-x-4 rtl:space-x-reverse">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate dark:text-white">
                  Item 3
                </p>
                <p className="text-sm text-gray-500 truncate dark:text-gray-400">
                  2018-09-19T01:30:00.000Z
                </p>
              </div>
              <div className="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                <span className="bg-green-100 text-xs font-medium me-2 px-2.5 py-0.5 rounded dark:bg-green-700">
                  Success
                </span>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
  );
}

// Node settings and interaction information
function ColTwo() {
  return (
    <div className="flex flex-col grow gap-1 w-full md:w-80">
      <div className="flex-1 bg-zinc-900 py-4 px-2 rounded-lg border border-stone-900">
        <WhenDo />
      </div>
      <div className="flex-1 bg-zinc-900 py-4 px-2 rounded-lg border border-stone-900">
        <Header
          title={"Endpoint"}
          moreCB={() => {
            console.log("moreCB");
          }}
        />

        <div className="flex align-center justify-center items-center my-3 gap-3">
          <input
            type="text"
            id="disabled-input"
            aria-label="disabled input"
            className="box_input_inset_shadow disabledmb-6 text-gray-900 text-sm rounded-lg border-stone-900 block w-full p-4 cursor-not-allowed dark:text-gray-400"
            value="https://leafnode.app/dispatch/[SOME_NODE_ID]"
            disabled
          />
          <div className="p-3 cursor-pointer">
            <i className="fa-regular fa-copy"></i>
          </div>
        </div>
        <span className="bg-orange-100 text-xs font-medium mx-1 px-2 py-0.5 rounded dark:bg-orange-700">
          POST
        </span>
        <hr className="border-zinc-900 my-3"/>
        <div className="flex flex-col gap-3">
          {/* Enable the node */}
          <label className="flex items-center cursor-pointer px-2">
            <span className="flex-1 font-medium text-gray-900 dark:text-gray-300">Enable</span>
            <div>
              <input type="checkbox" value="" className="sr-only peer" />
              <div className="
                relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4
                peer-focus:ring-grey-300 dark:peer-focus:ring-zinc-800 rounded-full peer
                dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full 
                peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px]
                after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5
                after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
            </div>
          </label>
          {/* Public Access - Public/Private - requires header generation */}
          <label className="flex items-center cursor-pointer px-2">
            <span className="flex-1 font-medium text-gray-900 dark:text-gray-300">Logs</span>
            <div>
              <input type="checkbox" value="" className="sr-only peer" />
              <div className="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:zinc-gray-300 dark:peer-focus:ring-zinc-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-green-700"></div>
            </div>
          </label>
        </div>
      </div>
    </div>
  );
}


// This is the main renderer
function App() {

  // Rendering the data for the chart
  useEffect(() => {
    const options = {
      series: [
        {
          name: "Errors",
          data: [31, 40, 28, 51, 42, 109, 100],
        },
        {
          name: "Success",
          data: [11, 32, 45, 32, 34, 52, 41],
        },
      ],
      colors: ["#8e163f", "#25944f"],
      fill: {
        gradient: {
          enabled: true,
          opacityFrom: 1,
          opacityTo: 0,
        },
      },
      chart: {
        height: 320,
        type: "area",
        width: "100%", // Chart takes full width
        toolbar: {
          show: false, // Hides the toolbar for a cleaner look
        },
        zoom: {
          enabled: false,
        },
      },
      dataLabels: {
        enabled: false,
      },
      legend: {
        show: false,
      },
      stroke: {
        curve: "smooth",
      },
      xaxis: {
        type: "datetime",
        categories: [
          "2018-09-19T00:00:00.000Z",
          "2018-09-19T01:30:00.000Z",
          "2018-09-19T02:30:00.000Z",
          "2018-09-19T03:30:00.000Z",
          "2018-09-19T04:30:00.000Z",
          "2018-09-19T05:30:00.000Z",
          "2018-09-19T06:30:00.000Z",
        ],
        axisBorder: {
          show: false, // Hides the x-axis line
        },
        labels: {
          show: false,
        },
      },
      yaxis: {
        show: false, // Hides y-axis grid lines and labels
      },
      grid: {
        show: false, // Turn off grid lines
      },
      tooltip: {
        x: {
          format: "dd/MM/yy HH:mm",
        },
        theme: "dark",
      },
      responsive: [
        {
          breakpoint: 480, // Adjusts settings for screen widths less than 480px
          options: {
            chart: {
              height: 300, // Smaller chart height on smaller screens
            },
            xaxis: {
              labels: {
                rotate: 0, // Avoids label rotation on small screens
              },
            },
          },
        },
      ],
    };

    var chart = new ApexCharts(document.querySelector("#chart"), options);
    chart.render();

    return () => {
      chart.destroy();
    };
  }, []);

  return (
    <>
      {/* This is a back button that will be back to the main section */}
      <div
        className="p-5 cursor-pointer"
        onClick={() => console.log("BACK: Dashboard")}
      >
        <i className="fa-solid fa-arrow-left"></i> back
      </div>

      {/* SETUP INPUT */}
      <div className="flex flex-col gap-1 py-1">
        <div className="bg-zinc-900 rounded-lg py-4 px-2 border border-stone-900">
          <Header
            title={"Node Name"}
            settingCB={() => {
              console.log("settingCB");
            }}
          />
        </div>
        {/* <div className="self-center node_vertical_line" /> */}
      </div>
      <MainWrapper>
        <ColOne />
        <ColTwo />
      </MainWrapper>
      
      {/* Leafnode */}
      <div className="py-2 text-center text-zinc-600">
        leafnode.app | <a className="text-zinc-500" href="https://github.com/toreanjoel" target="_blank">toreanjoel</a>
      </div>
    </>
  );
}

export default App;
